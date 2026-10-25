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
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/pitabwire/util"
)

// ClientStandingChecker tells whether a client may be lent to. A client is
// registered CREATED and becomes ACTIVE when activated on the identity
// service: its KYC verified and the person's consent given.
type ClientStandingChecker interface {
	RequireActive(ctx context.Context, clientID string) error
}

type fieldClientStanding struct {
	fieldCli fieldv1connect.FieldServiceClient
}

// NewFieldClientStanding builds the production checker.
func NewFieldClientStanding(fieldCli fieldv1connect.FieldServiceClient) ClientStandingChecker {
	return &fieldClientStanding{fieldCli: fieldCli}
}

func (c *fieldClientStanding) RequireActive(ctx context.Context, clientID string) error {
	clientID = strings.TrimSpace(clientID)
	if clientID == "" || c == nil || c.fieldCli == nil {
		return ErrClientStandingUnverifiable
	}
	resp, err := c.fieldCli.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		util.Log(ctx).WithError(err).WithField("client_id", clientID).
			Warn("client standing check: client could not be loaded")
		return ErrClientStandingUnverifiable
	}
	if resp.GetData().GetState() != commonv1.STATE_ACTIVE {
		return ErrClientNotActive
	}
	return nil
}

// WithClientStanding installs the check that a loan is approved only for an
// activated client. Without it (local development, tests) the check is off.
func WithClientStanding(c ClientStandingChecker) Option {
	return func(o *options) { o.clientStanding = c }
}
