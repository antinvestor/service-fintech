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
	"fmt"
	"net/url"
	"os"
	"strings"

	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/queue"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
)

// BroadcastSubscription is the per-replica fan-out subscription that makes
// limits.policy.invalidate.v1 reach every replica, not just the one that wins
// the competing-consumer events queue. Register it with
// frame.WithRegisterSubscriber(Reference, URL, Worker) next to the events
// subscription; the publish side (PolicyBusiness → events manager) is
// unchanged.
type BroadcastSubscription struct {
	// Reference is unique per replica so frame's registry, and any broker that
	// names subscriptions after it, never shares one cursor between pods.
	Reference string
	// URL is the events subscribe URL with every shared-consumer parameter
	// removed, so each replica opens its own plain subscription on the topic.
	URL string
	// Worker filters the event header for the invalidation event and purges
	// the cache; every other event on the topic is acknowledged untouched.
	Worker queue.SubscribeWorker
}

// ErrBroadcastUnsupported is returned when the configured events subscribe
// URL cannot express a per-replica fan-out subscription.
var ErrBroadcastUnsupported = errors.New("policy invalidation broadcast: queue URL cannot fan out per replica")

const (
	// broadcastReferencePrefix is the frame subscriber reference prefix.
	broadcastReferencePrefix = "limits.policy.invalidate.broadcast."
	// instanceSuffixLen is the random suffix appended to the hostname so two
	// processes on one host never share a subscription reference.
	instanceSuffixLen = 6
)

// sharedConsumerParams lists the natspubsub query parameters that turn a
// subscription into a shared queue group (core NATS) or a durable consumer
// (JetStream). A broadcast subscription must carry none of them.
func sharedConsumerParams() []string {
	return []string{"consumer_durable_name", "consumer_name"}
}

// NewPolicyInvalidateBroadcast builds the fan-out subscription for cache.
// eventsSubscribeURL is the service's events subscribe URL
// (config.GetEventsQueueSubscribeURL()); instanceID identifies this replica
// (see InstanceID). It fails with ErrBroadcastUnsupported for push:// and
// gcppubsub:// URLs, where a per-replica subscription would have to exist on
// the broker side before the pod starts.
func NewPolicyInvalidateBroadcast(
	cache *PolicyCache,
	eventsSubscribeURL, instanceID string,
) (*BroadcastSubscription, error) {
	broadcastURL, err := BroadcastSubscriberURL(eventsSubscribeURL)
	if err != nil {
		return nil, err
	}
	instanceID = strings.TrimSpace(instanceID)
	if instanceID == "" {
		instanceID = InstanceID()
	}
	return &BroadcastSubscription{
		Reference: broadcastReferencePrefix + instanceID,
		URL:       broadcastURL,
		Worker:    &policyInvalidateWorker{handler: NewPolicyInvalidateHandler(cache)},
	}, nil
}

// BroadcastSubscriberURL derives the per-replica subscription URL from the
// events subscribe URL. mem:// topics fan out to every subscription by
// construction; nats:// fans out once the shared-consumer parameters are
// stripped (each replica then holds its own plain or ephemeral subscription on
// the same subject). Any other scheme cannot broadcast.
func BroadcastSubscriberURL(eventsSubscribeURL string) (string, error) {
	u, err := url.Parse(strings.TrimSpace(eventsSubscribeURL))
	if err != nil || u.Scheme == "" {
		return "", fmt.Errorf("%w: invalid URL %q", ErrBroadcastUnsupported, eventsSubscribeURL)
	}
	switch strings.ToLower(u.Scheme) {
	case "mem":
		return u.String(), nil
	case "nats":
		q := u.Query()
		for _, p := range sharedConsumerParams() {
			q.Del(p)
		}
		u.RawQuery = q.Encode()
		return u.String(), nil
	default:
		return "", fmt.Errorf("%w: scheme %q", ErrBroadcastUnsupported, u.Scheme)
	}
}

// InstanceID names this replica for the subscription reference: the hostname
// (the pod name on Kubernetes / Cloud Run) plus a random suffix, so two
// processes on one host, or a restarted pod reusing a name, never collide.
func InstanceID() string {
	host, err := os.Hostname()
	if err != nil || strings.TrimSpace(host) == "" {
		host = "replica"
	}
	return host + "-" + strings.ToLower(util.RandomAlphaNumericString(instanceSuffixLen))
}

// policyInvalidateWorker is the raw queue worker behind the broadcast
// subscription. It sees every event published on the topic and acts only on
// limits.policy.invalidate.v1; everything else is acknowledged so the
// per-replica cursor keeps moving.
type policyInvalidateWorker struct {
	handler *PolicyInvalidateHandler
}

func (w *policyInvalidateWorker) Handle(ctx context.Context, metadata map[string]string, message []byte) error {
	if metadata[fevents.EventHeaderName] != events.EventPolicyInvalidate {
		return nil
	}
	payload := &events.PolicyInvalidatePayload{}
	if err := json.Unmarshal(message, payload); err != nil {
		// A malformed invalidation can never be replayed into a good one;
		// purge anyway so the replica is at worst over-eager, never stale.
		util.Log(ctx).WithError(err).Warn("limits: unreadable policy invalidation broadcast; purging cache")
		return w.handler.Execute(ctx, &events.PolicyInvalidatePayload{})
	}
	if err := w.handler.Validate(ctx, payload); err != nil {
		return err
	}
	return w.handler.Execute(ctx, payload)
}
