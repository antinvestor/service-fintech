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

package business_test

import (
	"net/http"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/config"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

func TestBroadcastSubscriberURL(t *testing.T) {
	cases := []struct {
		name    string
		in      string
		want    string
		wantErr bool
	}{
		{
			name: "mem topic passes through",
			in:   "mem://frame.events.internal_._queue",
			want: "mem://frame.events.internal_._queue",
		},
		{
			name: "nats durable consumer is stripped",
			in:   "nats://nats.fintech.svc:4222?subject=fintech.limits.events&consumer_durable_name=limits&jetstream=true",
			want: "nats://nats.fintech.svc:4222?jetstream=true&subject=fintech.limits.events",
		},
		{
			name: "nats consumer name is stripped",
			in:   "nats://nats.fintech.svc:4222?subject=fintech.limits.events&consumer_name=limits-events",
			want: "nats://nats.fintech.svc:4222?subject=fintech.limits.events",
		},
		{
			name: "nats plain subscription is unchanged",
			in:   "nats://nats.fintech.svc:4222?subject=fintech.limits.events",
			want: "nats://nats.fintech.svc:4222?subject=fintech.limits.events",
		},
		{name: "push cannot fan out", in: "push://events", wantErr: true},
		{name: "gcppubsub cannot fan out", in: "gcppubsub://projects/p/subscriptions/s", wantErr: true},
		{name: "empty is invalid", in: "", wantErr: true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := business.BroadcastSubscriberURL(tc.in)
			if tc.wantErr {
				require.ErrorIs(t, err, business.ErrBroadcastUnsupported)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tc.want, got)
		})
	}
}

func TestNewPolicyInvalidateBroadcast_ReferenceIsPerReplica(t *testing.T) {
	cache := business.NewPolicyCache(&countingCandidateRepo{}, time.Minute)

	a, err := business.NewPolicyInvalidateBroadcast(cache, "mem://limits.events", "")
	require.NoError(t, err)
	b, err := business.NewPolicyInvalidateBroadcast(cache, "mem://limits.events", "")
	require.NoError(t, err)
	assert.NotEqual(t, a.Reference, b.Reference, "two replicas must never share a subscription reference")
	assert.True(t, strings.HasPrefix(a.Reference, "limits.policy.invalidate.broadcast."), a.Reference)
	assert.Equal(t, "mem://limits.events", a.URL)
	assert.NotNil(t, a.Worker)

	named, err := business.NewPolicyInvalidateBroadcast(cache, "mem://limits.events", "pod-7")
	require.NoError(t, err)
	assert.Equal(t, "limits.policy.invalidate.broadcast.pod-7", named.Reference)

	_, err = business.NewPolicyInvalidateBroadcast(cache, "push://events", "pod-7")
	require.ErrorIs(t, err, business.ErrBroadcastUnsupported)
}

// TestPolicyInvalidateBroadcast_ReachesEveryReplica runs two replicas' worth
// of cache + broadcast subscription against one in-memory topic, publishes a
// single invalidation the way the events manager does, and asserts both
// caches drop their entry; an unrelated event on the same topic leaves them
// warm.
func TestPolicyInvalidateBroadcast_ReachesEveryReplica(t *testing.T) {
	const topic = "mem://limits.events.broadcast"
	const publisherRef = "limits-events"

	type replica struct {
		store *countingCandidateRepo
		cache *business.PolicyCache
	}
	replicas := make([]replica, 2)
	opts := []frame.Option{frame.WithRegisterPublisher(publisherRef, topic)}
	for i := range replicas {
		store := &countingCandidateRepo{results: []*models.Policy{{Action: models.ActionLoanDisbursement}}}
		cache := business.NewPolicyCache(store, time.Hour) // only the broadcast can evict
		sub, err := business.NewPolicyInvalidateBroadcast(cache, topic, "replica-"+strconv.Itoa(i))
		require.NoError(t, err)
		replicas[i] = replica{store: store, cache: cache}
		opts = append(opts, frame.WithRegisterSubscriber(sub.Reference, sub.URL, sub.Worker))
	}

	port, err := frametests.GetFreePort(t.Context())
	require.NoError(t, err)
	driverOpt, _ := frametests.WithBoundHTTPTestDriver()
	cfg := config.ConfigurationDefault{HTTPServerPort: strconv.Itoa(port)}
	ctx, svc := frame.NewServiceWithContext(t.Context(),
		append([]frame.Option{
			frame.WithName("limits-broadcast-test"),
			frame.WithConfig(&cfg),
			driverOpt,
			frame.WithHTTPHandler(http.NotFoundHandler()),
		}, opts...)...,
	)
	defer svc.Stop(ctx)
	require.NoError(t, svc.Run(ctx, ""), "Run returns once the listener is bound and queues are up")

	q := repository.CandidateQuery{
		TenantID: "tenant-a", OrgUnitID: "ou-1", Action: models.ActionLoanDisbursement, CurrencyCode: "KES",
	}
	warm := func() {
		for _, r := range replicas {
			_, findErr := r.cache.FindCandidates(ctx, q)
			require.NoError(t, findErr)
		}
	}
	calls := func() []int {
		out := make([]int, len(replicas))
		for i, r := range replicas {
			out[i] = r.store.calls
		}
		return out
	}

	warm()
	warm()
	require.Equal(t, []int{1, 1}, calls(), "both caches are warm")

	// An unrelated event on the shared topic must not disturb either cache.
	require.NoError(t, svc.QueueManager().Publish(ctx, publisherRef,
		events.ApprovalEventPayload{ReservationID: "r1"},
		map[string]string{fevents.EventHeaderName: events.EventApprovalApproved}))
	time.Sleep(100 * time.Millisecond)
	warm()
	require.Equal(t, []int{1, 1}, calls(), "an unrelated event leaves both caches warm")

	require.NoError(t, svc.QueueManager().Publish(ctx, publisherRef,
		events.PolicyInvalidatePayload{PolicyID: "pol-1", TenantID: "tenant-a"},
		map[string]string{fevents.EventHeaderName: events.EventPolicyInvalidate}))

	require.Eventually(t, func() bool {
		for _, r := range replicas {
			if _, findErr := r.cache.FindCandidates(ctx, q); findErr != nil {
				return false
			}
		}
		got := calls()
		return got[0] == 2 && got[1] == 2
	}, 5*time.Second, 20*time.Millisecond, "every replica must refetch after one invalidation")
}
