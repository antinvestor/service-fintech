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
	"fmt"
)

const (
	BadRequest      = 400
	Unauthorised    = 401
	Forbidden       = 403
	NotFound        = 404
	Conflict        = 409
	Gone            = 410
	Unprocessable   = 422
	TooManyRequests = 429

	InternalServerError = 500
	BadGateway          = 502
	ServiceUnavailable  = 503
	GatewayTimeout      = 504
)

var (
	ErrInvalidInput = Error{ //nolint:gochecknoglobals // sentinel error
		code:    BadRequest,
		message: "Invalid input provided",
	}
	ErrMissingRequiredData = Error{ //nolint:gochecknoglobals // sentinel error
		code:    BadRequest,
		message: "Required data is missing",
	}
	ErrDataNotFound = Error{ //nolint:gochecknoglobals // sentinel error
		code:    NotFound,
		message: "Requested data not found",
	}
	ErrDataConflict = Error{ //nolint:gochecknoglobals // sentinel error
		code:    Conflict,
		message: "Data conflict occurred",
	}
	ErrDataValidation = Error{ //nolint:gochecknoglobals // sentinel error
		code:    Unprocessable,
		message: "Data validation failed",
	}
	ErrForbiddenAccess = Error{ //nolint:gochecknoglobals // sentinel error
		code:    Forbidden,
		message: "Access forbidden",
	}
)

type Error struct {
	code    int
	message string
}

func NewError(code int, message string) *Error {
	return &Error{
		code:    code,
		message: message,
	}
}

func (e *Error) Error() string {
	return e.message
}

// Message returns the caller-facing description without the code.
func (e *Error) Message() string {
	return e.message
}

func (e *Error) ErrorCode() int {
	return e.code
}

func (e *Error) Extend(message string) *Error {
	return &Error{
		code:    e.code,
		message: fmt.Sprintf("%s - %s", e.message, message),
	}
}

func (e *Error) IsRetriable() bool {
	return e.code >= 500 && e.code < 600
}
