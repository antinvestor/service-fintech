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
	"errors"
	"fmt"
	"strings"
	"time"

	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	tenancyv1 "buf.build/gen/go/antinvestor/tenancy/protocolbuffers/go/tenancy/v1"
	"connectrpc.com/connect"
	"github.com/hashicorp/golang-lru/v2/expirable"
)

// ErrPartitionChainUnavailable means the partition a transaction belongs to
// could not be placed in the hierarchy. Evaluation fails closed on it: a cap
// set on an ancestor partition that silently stops applying is not a cap.
var ErrPartitionChainUnavailable = errors.New("limits: partition hierarchy unavailable")

// PartitionAncestry returns a partition followed by every ancestor up to the
// root. Policies are tiered along this chain: a policy set on any partition
// in it applies to the transaction, and all of them must pass, so a child
// partition can tighten what its ancestors allow but never exceed it, at any
// depth.
type PartitionAncestry interface {
	Chain(ctx context.Context, partitionID string) ([]string, error)
}

const (
	partitionChainCacheSize  = 4096
	defaultPartitionChainTTL = 5 * time.Minute
)

type tenancyPartitionAncestry struct {
	cli   tenancyv1connect.TenancyServiceClient
	cache *expirable.LRU[string, []string]
}

// NewPartitionAncestry resolves partition parents from the tenancy service.
// The tree changes rarely (a partition is created for a new organization or
// branch), so chains are cached for ttl.
func NewPartitionAncestry(cli tenancyv1connect.TenancyServiceClient, ttl time.Duration) PartitionAncestry {
	if ttl <= 0 {
		ttl = defaultPartitionChainTTL
	}
	return &tenancyPartitionAncestry{
		cli:   cli,
		cache: expirable.NewLRU[string, []string](partitionChainCacheSize, nil, ttl),
	}
}

func (a *tenancyPartitionAncestry) Chain(ctx context.Context, partitionID string) ([]string, error) {
	partitionID = strings.TrimSpace(partitionID)
	if partitionID == "" {
		return nil, nil
	}
	if hit, ok := a.cache.Get(partitionID); ok {
		return hit, nil
	}
	if a.cli == nil {
		return nil, fmt.Errorf("%w: tenancy client not configured", ErrPartitionChainUnavailable)
	}
	resp, err := a.cli.GetPartitionParents(
		ctx,
		connect.NewRequest(&tenancyv1.GetPartitionParentsRequest{Id: partitionID}),
	)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrPartitionChainUnavailable, err)
	}
	chain, err := chainFromParents(partitionID, resp.Msg.GetData())
	if err != nil {
		return nil, err
	}
	a.cache.Add(partitionID, chain)
	return chain, nil
}

// chainFromParents orders the partition and its parents from the partition
// itself up to the root. The tenancy service returns parents root first and
// stops after a fixed depth; a chain whose topmost member still names a
// parent was cut short, and the caps above the cut would be missed, so it is
// refused rather than used.
func chainFromParents(partitionID string, parents []*tenancyv1.PartitionObject) ([]string, error) {
	chain := []string{partitionID}
	seen := map[string]bool{partitionID: true}
	for i := len(parents) - 1; i >= 0; i-- {
		id := strings.TrimSpace(parents[i].GetId())
		if id == "" || seen[id] {
			continue
		}
		seen[id] = true
		chain = append(chain, id)
	}
	if len(parents) > 0 && strings.TrimSpace(parents[0].GetParentId()) != "" {
		return nil, fmt.Errorf(
			"%w: partition %s is deeper than the tenancy service walks",
			ErrPartitionChainUnavailable,
			partitionID,
		)
	}
	return chain, nil
}
