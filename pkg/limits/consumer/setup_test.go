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

package consumer_test

import (
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

type fakeLimits struct {
	limitsv1connect.LimitsServiceClient
}

func TestRequireForGates(t *testing.T) {
	gates := map[string]bool{"loan_disbursement": true, "loan_repayment": false}

	assert.NoError(t, consumer.RequireForGates(nil, nil, map[string]bool{"x": false}), "no gate on, no client needed")
	assert.NoError(t, consumer.RequireForGates(fakeLimits{}, nil, gates))

	err := consumer.RequireForGates(nil, nil, gates)
	require.ErrorContains(t, err, "loan_disbursement")
	require.ErrorContains(t, err, "LIMITS_SERVICE_URI")

	assert.ErrorContains(t, consumer.RequireForGates(nil, errors.New("dial failed"), gates), "dial failed")
}
