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
)

// ErrNoClientForProfile is returned when the identity platform holds no client
// row for the caller's profile. It is a distinguishable not-found so callers
// can answer "you are not a borrowing client" rather than a generic failure.
var ErrNoClientForProfile = errors.New("seed: no client is linked to the profile")

// ClientResolver maps the authenticated caller's profile onto the client
// record seed lends to. Tokens carry a profile id; every seed credit decision
// is scoped by client id, so the two have to be bridged on every request.
type ClientResolver interface {
	// ResolveByProfileID returns the client id linked to the profile, or
	// ErrNoClientForProfile when the profile owns no client.
	ResolveByProfileID(ctx context.Context, profileID string) (clientID string, err error)
}
