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

package apperrors

import (
	"errors"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
)

// CleanErr converts any error produced by the business or repository layers
// into a connect error that is safe to return to a client.
//
// Resolution order:
//  1. An existing *connect.Error is returned unchanged (handlers and
//     interceptors already decided what the caller may see).
//  2. An *Error carries an explicit HTTP-style code and a message written
//     for callers; both are mapped onto the wire.
//  3. A missing-row error becomes NotFound.
//  4. Anything else (driver errors, constraint violations, bare fmt.Errorf)
//     keeps the connect code frame derives from it, but the message is
//     replaced by a generic one so table, column and index names never leak.
func CleanErr(err error) *connect.Error {
	if err == nil {
		return nil
	}

	var cerr *connect.Error
	if errors.As(err, &cerr) {
		if cerr.IsRemote() {
			// A peer's verdict: connect v2 refuses to forward it as this
			// handler's own (it would reach the caller as Internal with no
			// message), so re-author it locally with the peer's code and
			// message, as connect v1 forwarded it.
			return connect.NewError(cerr.Code(), cerr.Message()).WithCause(err)
		}
		return cerr
	}

	var appErr *Error
	if errors.As(err, &appErr) {
		return connect.NewError(appErr.ConnectCode(), appErr.Message())
	}

	if data.ErrorIsNoRows(err) {
		return connect.NewError(connect.CodeNotFound, ErrDataNotFound.Message())
	}

	api := data.ErrorConvertToAPI(err)
	return connect.NewError(api.Code(), publicMessage(api.Code()))
}

// ConnectCode maps the HTTP-style code carried by an Error onto a connect code.
func (e *Error) ConnectCode() connect.Code {
	switch e.code {
	case BadRequest:
		return connect.CodeInvalidArgument
	case Unauthorised:
		return connect.CodeUnauthenticated
	case Forbidden:
		return connect.CodePermissionDenied
	case NotFound:
		return connect.CodeNotFound
	case Conflict:
		return connect.CodeAlreadyExists
	case Gone, Unprocessable:
		return connect.CodeFailedPrecondition
	case TooManyRequests:
		return connect.CodeResourceExhausted
	case BadGateway, ServiceUnavailable:
		return connect.CodeUnavailable
	case GatewayTimeout:
		return connect.CodeDeadlineExceeded
	default:
		return connect.CodeInternal
	}
}

// publicMessage is what a caller sees for an error that was not written for
// them. It names the failure class only.
func publicMessage(code connect.Code) string {
	switch code {
	case connect.CodeAlreadyExists:
		return "a record with the same identity already exists"
	case connect.CodeInvalidArgument:
		return "the request violates a data constraint"
	case connect.CodeNotFound:
		return ErrDataNotFound.Message()
	case connect.CodeUnavailable:
		return "a dependency is temporarily unavailable"
	case connect.CodeAborted:
		return "the operation was aborted, retry the request"
	case connect.CodeDeadlineExceeded:
		return "the operation timed out"
	case connect.CodeCanceled, connect.CodeUnknown, connect.CodeFailedPrecondition,
		connect.CodeOutOfRange, connect.CodeUnimplemented, connect.CodeInternal,
		connect.CodeDataLoss, connect.CodeUnauthenticated, connect.CodePermissionDenied,
		connect.CodeResourceExhausted:
		return "an internal error occurred"
	default:
		return "an internal error occurred"
	}
}
