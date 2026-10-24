// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package business

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect"
	"github.com/hashicorp/golang-lru/v2/expirable"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"
	"gorm.io/datatypes"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// AttributeResolver fetches a subject's attributes for predicate evaluation.
//
// Read-through cache order:
//  1. In-process LRU map (configurable TTL, default 60 s). Hit → return.
//  2. SubjectAttributeRepository (DB-backed snapshot). Fresh hit → populate LRU + return.
//  3. Identity service. Success → persist to DB, populate LRU, return.
//
// For non-client subjects (account, product, organization, org_unit,
// workforce_member) the resolver returns an empty attribute map for v1.
// These subject types do not yet have queryable attributes in identity.
//
// On identity fetch failure the resolver returns (nil, nil). Callers must
// treat a nil map as "attributes unavailable", not as "no attributes": for an
// enforce-mode policy the reservation path fails closed on it, because a
// KYC-tier cap that silently stops applying whenever identity is down is not
// a cap at all.
type AttributeResolver interface {
	Get(ctx context.Context, subjectType models.Subject, subjectID string) (map[string]any, error)
	Invalidate(subjectType models.Subject, subjectID string)
}

type attributeResolver struct {
	repo           repository.SubjectAttributeRepository
	identityClient identityv1connect.IdentityServiceClient
	// fieldClient resolves borrowers: the lending flows send field-service
	// client ids as CLIENT subjects. Investors are looked up through
	// identityClient when the field service does not know the id.
	fieldClient fieldv1connect.FieldServiceClient
	// cache is a bounded expirable LRU. Capacity of 10 000 entries bounds
	// memory growth; the TTL (default 60 s) bounds staleness. The expirable
	// LRU handles eviction internally — no separate janitor goroutine needed.
	cache *expirable.LRU[string, cachedAttrs]
	ttl   time.Duration
}

type cachedAttrs struct {
	attrs map[string]any
}

const (
	// defaultAttrTTL caps how long cached subject attributes stay fresh.
	defaultAttrTTL = 60 * time.Second
	// attrCacheSize bounds the in-process attribute LRU.
	attrCacheSize = 10000
)

// NewAttributeResolver constructs a resolver. A nil identity client makes
// the resolver "DB-only" — useful in tests and as a graceful fallback when
// the identity service is misconfigured.
func NewAttributeResolver(
	repo repository.SubjectAttributeRepository,
	identityClient identityv1connect.IdentityServiceClient,
	ttl time.Duration,
	opts ...AttributeResolverOption,
) AttributeResolver {
	if ttl == 0 {
		ttl = defaultAttrTTL
	}
	r := &attributeResolver{
		repo:           repo,
		identityClient: identityClient,
		cache:          expirable.NewLRU[string, cachedAttrs](attrCacheSize, nil, ttl),
		ttl:            ttl,
	}
	for _, opt := range opts {
		if opt != nil {
			opt(r)
		}
	}
	return r
}

// AttributeResolverOption configures optional look-ups of the resolver.
type AttributeResolverOption func(*attributeResolver)

// WithFieldClients resolves CLIENT subjects through the field service first,
// which owns the borrowers that loans and savings send as subjects.
func WithFieldClients(cli fieldv1connect.FieldServiceClient) AttributeResolverOption {
	return func(r *attributeResolver) { r.fieldClient = cli }
}

// Get returns the attribute map for the given subject.
func (r *attributeResolver) Get(
	ctx context.Context,
	subjectType models.Subject,
	subjectID string,
) (map[string]any, error) {
	if subjectType != models.SubjectClient {
		// v1: only client subjects have queryable attributes in identity.
		return map[string]any{}, nil
	}

	key := string(subjectType) + ":" + subjectID

	// 1. LRU check. The expirable.LRU handles TTL internally.
	if c, ok := r.cache.Get(key); ok {
		return c.attrs, nil
	}

	// 2. DB snapshot check.
	snap, err := r.repo.Get(ctx, subjectType, subjectID)
	if err == nil && snap != nil && time.Since(snap.FetchedAt) < r.ttl {
		attrs := decodeAttrs(snap.Attributes)
		r.populate(key, attrs)
		return attrs, nil
	}

	// 3. Identity fetch.
	attrs, fetchErr := r.fetchFromIdentity(ctx, subjectID)
	if fetchErr != nil {
		util.Log(ctx).
			WithError(fetchErr).
			WithField("subject_type", string(subjectType)).
			WithField("subject_id", subjectID).
			Warn("attribute resolver: identity fetch failed; falling back to empty attributes")
		//nolint:nilnil // graceful degradation: callers treat a nil map as "no attributes"
		return nil, nil
	}

	// Persist + populate LRU.
	if attrs != nil {
		j, _ := json.Marshal(attrs)
		_ = r.repo.Upsert(ctx, &models.SubjectAttributeSnapshot{
			SubjectType: subjectType,
			SubjectID:   subjectID,
			Attributes:  datatypes.JSON(j),
			FetchedAt:   time.Now().UTC(),
		})
		r.populate(key, attrs)
	}
	return attrs, nil
}

// Invalidate removes the LRU entry for the given subject. The next call to
// Get will re-check the DB and identity service.
func (r *attributeResolver) Invalidate(subjectType models.Subject, subjectID string) {
	key := string(subjectType) + ":" + subjectID
	r.cache.Remove(key)
}

func (r *attributeResolver) populate(key string, attrs map[string]any) {
	r.cache.Add(key, cachedAttrs{attrs: attrs})
}

func decodeAttrs(j datatypes.JSON) map[string]any {
	if len(j) == 0 {
		return map[string]any{}
	}
	var m map[string]any
	_ = json.Unmarshal(j, &m)
	return m
}

// fetchFromIdentity pulls the subject's attributes from the identity service
// and projects them into a flat map.
//
// Identity model mapping:
//   - "client" subjects in the limits service map to InvestorObject in
//     the identity service (InvestorGet RPC).
//   - InvestorObject exposes: id, profile_id, name, state, properties.
//   - kyc_tier and country_code are not first-class proto fields on
//     InvestorObject in the current identity API version; they are read from
//     the Properties structpb, which is where the identity service publishes
//     them. A dedicated field on InvestorObject is listed as a proto
//     follow-up.
//
// Returns (nil, nil) when the client isn't configured (graceful degradation).
//
// A borrower is looked up in the field service first, then as an investor.
// An id neither service knows is an error like any other failure: whether a
// filtered policy matches it cannot be known, so the reservation path fails
// closed for enforce policies rather than letting an unknown subject skip a
// stricter tier.
func (r *attributeResolver) fetchFromIdentity(ctx context.Context, clientID string) (map[string]any, error) {
	if r.identityClient == nil && r.fieldClient == nil {
		//nolint:nilnil // documented contract: nil map when no identity client is configured
		return nil, nil
	}

	if r.fieldClient != nil {
		attrs, err := r.fetchFieldClient(ctx, clientID)
		if err == nil {
			return attrs, nil
		}
		if connect.CodeOf(err) != connect.CodeNotFound || r.identityClient == nil {
			return nil, err
		}
	}

	resp, err := r.identityClient.InvestorGet(
		ctx,
		connect.NewRequest(&identityv1.InvestorGetRequest{Id: clientID}),
	)
	if err != nil {
		return nil, err
	}

	inv := resp.Msg.GetData()
	if inv == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("subject not found"))
	}

	attrs := map[string]any{
		"state":      inv.GetState().String(),
		"name":       inv.GetName(),
		"profile_id": inv.GetProfileId(),
	}

	// Merge any entries from the properties bag. This covers dynamic
	// attributes such as kyc_tier / country_code that identity services
	// may store there until first-class proto fields are added.
	mergeProperties(attrs, inv.GetProperties())

	return attrs, nil
}

// fetchFieldClient projects a field-service client into attributes: state,
// name, profile, owning team and every key of its properties bag (where an
// agent records, for example, the limit tier the client is held to).
func (r *attributeResolver) fetchFieldClient(ctx context.Context, clientID string) (map[string]any, error) {
	resp, err := r.fieldClient.ClientGet(ctx, connect.NewRequest(&fieldv1.ClientGetRequest{Id: clientID}))
	if err != nil {
		return nil, err
	}
	client := resp.Msg.GetData()
	if client == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("client not found"))
	}
	attrs := map[string]any{
		"state":          client.GetState().String(),
		"name":           client.GetName(),
		"profile_id":     client.GetProfileId(),
		"owning_team_id": client.GetOwningTeamId(),
	}
	mergeProperties(attrs, client.GetProperties())
	return attrs, nil
}

// mergeProperties adds the subject's free-form properties to its attributes
// without letting them overwrite a system-derived key: a properties bag that
// field staff can edit must not be able to claim, say, a different state.
// Properties such as a client's limit tier are editable by the responsible
// agent on purpose; a tier policy is evaluated on top of every partition cap,
// so it can only tighten, never replace, the caps set above the agent.
func mergeProperties(attrs map[string]any, props *structpb.Struct) {
	for k, v := range props.GetFields() {
		if _, systemKey := attrs[k]; systemKey {
			continue
		}
		attrs[k] = v.AsInterface()
	}
}
