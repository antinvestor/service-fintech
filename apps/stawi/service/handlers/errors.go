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

package handlers

import (
	"context"
	"errors"
	"net/http"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// Stable, machine-readable error codes returned beside the HTTP status. The
// workflow engine and operators key on these rather than on message text.
const (
	errorCodeInvalidRequest  = "invalid_request"
	errorCodeUnauthenticated = "unauthenticated"
	errorCodeForbidden       = "forbidden"
	errorCodeNotFound        = "not_found"
	errorCodeConflict        = "conflict"
	errorCodeGone            = "gone"
	errorCodeUnprocessable   = "unprocessable"
	errorCodeRateLimited     = "rate_limited"
	errorCodeUnavailable     = "unavailable"
	errorCodeTimeout         = "timeout"
	errorCodeInternal        = "internal"
)

// Caller-safe messages for errors that do not carry an authored message of
// their own (peer RPC failures, database errors, cancellations).
const (
	messageNotFound      = "the requested record was not found"
	messageConflict      = "the record was changed by another request"
	messageInvalid       = "the request is invalid"
	messageUnprocessable = "the operation is not allowed in the record's current state"
	messageForbidden     = "the caller may not perform this operation"
	messageUnavailable   = "a dependency is temporarily unavailable"
	messageTimeout       = "the operation timed out"
	messageInternal      = "an internal error occurred"
)

// classifyError decides the HTTP status and the caller-safe message for an
// error, by error class:
//
//   - *apperrors.Error carries an authored status and message; both are used.
//   - A Connect error from a peer (identity, ledger, loans) is mapped by code
//     and gets a generic message, since peer messages can name internal ids.
//   - Database errors: no rows → 404, duplicate key → 409.
//   - Context cancellation and deadline → 504, so the engine retries.
//   - Anything else is a 500 with a generic message.
func classifyError(err error) (int, string) {
	var appErr *apperrors.Error
	if errors.As(err, &appErr) {
		return appErr.ErrorCode(), appErr.Message()
	}

	var connectErr *connect.Error
	if errors.As(err, &connectErr) {
		return classifyConnectCode(connectErr.Code())
	}

	switch {
	case data.ErrorIsNoRows(err):
		return http.StatusNotFound, messageNotFound
	case data.ErrorIsDuplicateKey(err):
		return http.StatusConflict, messageConflict
	case errors.Is(err, context.DeadlineExceeded), errors.Is(err, context.Canceled):
		return http.StatusGatewayTimeout, messageTimeout
	default:
		return http.StatusInternalServerError, messageInternal
	}
}

func classifyConnectCode(code connect.Code) (int, string) {
	switch code {
	case connect.CodeNotFound:
		return http.StatusNotFound, messageNotFound
	case connect.CodeAlreadyExists, connect.CodeAborted:
		return http.StatusConflict, messageConflict
	case connect.CodeInvalidArgument, connect.CodeOutOfRange:
		return http.StatusBadRequest, messageInvalid
	case connect.CodeFailedPrecondition:
		return http.StatusUnprocessableEntity, messageUnprocessable
	case connect.CodePermissionDenied:
		return http.StatusForbidden, messageForbidden
	case connect.CodeUnauthenticated:
		return http.StatusUnauthorized, "an authenticated caller is required"
	case connect.CodeUnavailable, connect.CodeResourceExhausted:
		return http.StatusServiceUnavailable, messageUnavailable
	case connect.CodeDeadlineExceeded, connect.CodeCanceled:
		return http.StatusGatewayTimeout, messageTimeout
	case connect.CodeUnknown, connect.CodeUnimplemented, connect.CodeInternal, connect.CodeDataLoss:
		return http.StatusInternalServerError, messageInternal
	default:
		return http.StatusInternalServerError, messageInternal
	}
}

// errorCodeForStatus is the stable code that accompanies each HTTP status.
func errorCodeForStatus(status int) string {
	switch status {
	case http.StatusBadRequest:
		return errorCodeInvalidRequest
	case http.StatusUnauthorized:
		return errorCodeUnauthenticated
	case http.StatusForbidden:
		return errorCodeForbidden
	case http.StatusNotFound:
		return errorCodeNotFound
	case http.StatusConflict:
		return errorCodeConflict
	case http.StatusGone:
		return errorCodeGone
	case http.StatusUnprocessableEntity:
		return errorCodeUnprocessable
	case http.StatusTooManyRequests:
		return errorCodeRateLimited
	case http.StatusBadGateway, http.StatusServiceUnavailable:
		return errorCodeUnavailable
	case http.StatusGatewayTimeout:
		return errorCodeTimeout
	default:
		return errorCodeInternal
	}
}
