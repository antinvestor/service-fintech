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

// Package transferorder builds operations transfer orders.
package transferorder

import (
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

// Typed sets the order's type on obj and returns it. transfer_type is the
// field operations reads; the deprecated order_type carries the same value
// so an operations instance from before the enum still understands the
// order during a rolling deploy.
func Typed(obj *operationsv1.TransferOrderObject, transferType int) *operationsv1.TransferOrderObject {
	t := constants.SafeInt32FromInt(transferType)
	obj.TransferType = operationsv1.TransferOrderType(t)
	obj.OrderType = t //nolint:staticcheck // kept in step for older operations instances
	return obj
}

// TypeOf reads an order's type: transfer_type when set, else the
// deprecated order_type older callers send.
func TypeOf(obj *operationsv1.TransferOrderObject) int32 {
	if t := obj.GetTransferType(); t != operationsv1.TransferOrderType_TRANSFER_ORDER_TYPE_UNSPECIFIED {
		return int32(t)
	}
	return obj.GetOrderType() //nolint:staticcheck // legacy callers
}
