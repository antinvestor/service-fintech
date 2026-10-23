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
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

func TestNormalizeRepaymentChannel(t *testing.T) {
	cases := map[string]string{
		"CASH":           RepaymentChannelCash,
		" cash ":         RepaymentChannelCash,
		"Agent-Cash":     RepaymentChannelCash,
		"M-Pesa":         RepaymentChannelMobileMoney,
		"mobile money":   RepaymentChannelMobileMoney,
		"MOMO":           RepaymentChannelMobileMoney,
		"Bank Transfer":  RepaymentChannelBank,
		"eft":            RepaymentChannelBank,
		"Savings":        RepaymentChannelSavings,
		"wallet":         RepaymentChannelSavings,
		"":               RepaymentChannelOther,
		"carrier pigeon": RepaymentChannelOther,
	}
	for in, want := range cases {
		assert.Equal(t, want, NormalizeRepaymentChannel(in), "%q", in)
	}
}

func TestAgentCashAccountNaming(t *testing.T) {
	assert.Equal(t, "agent:profile-7:cash_in_hand", constants.AgentCashAccount("profile-7"))
}
