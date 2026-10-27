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
	"net"

	"connectrpc.com/connect/v2"
)

// isTransientLookupError reports whether a lookup failed because the peer
// could not answer, not because nothing matched. A payment whose lookup
// failed that way must be retried, never routed to the unidentified account:
// a no-match is a decision, a transport failure is not.
func isTransientLookupError(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
		return true
	}
	var connectErr *connect.Error
	if errors.As(err, &connectErr) {
		switch connectErr.Code() { //nolint:exhaustive // the rest are answers, not outages
		case connect.CodeUnavailable, connect.CodeDeadlineExceeded, connect.CodeInternal,
			connect.CodeUnknown, connect.CodeResourceExhausted, connect.CodeAborted:
			return true
		default:
			return false
		}
	}
	var netErr net.Error
	return errors.As(err, &netErr)
}
