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

package transferorder_test

import (
	"testing"

	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"google.golang.org/protobuf/reflect/protoreflect"

	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/transferorder"
)

func TestTypedAndTypeOf(t *testing.T) {
	obj := transferorder.Typed(&operationsv1.TransferOrderObject{}, constants.TransferTypeDisbursement)
	if obj.GetTransferType() != operationsv1.TransferOrderType_TRANSFER_ORDER_TYPE_DISBURSEMENT {
		t.Fatalf("transfer_type = %v", obj.GetTransferType())
	}
	if got := transferorder.TypeOf(obj); got != int32(constants.TransferTypeDisbursement) {
		t.Fatalf("TypeOf = %d", got)
	}
	// A legacy caller that only sets the deprecated order_type.
	legacy := &operationsv1.TransferOrderObject{}
	m := legacy.ProtoReflect()
	m.Set(m.Descriptor().Fields().ByName("order_type"), protoreflect.ValueOfInt32(42))
	if got := transferorder.TypeOf(legacy); got != 42 {
		t.Fatalf("legacy TypeOf = %d", got)
	}
}
