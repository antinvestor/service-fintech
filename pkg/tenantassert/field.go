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

package tenantassert

import (
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

// Field is the caller-supplied tenant carried by one request shape.
type Field struct {
	Get func() string
	Set func(string)
}

// FieldFunc locates the tenant field on a request message, or returns nil
// when the shape carries none and the header is the only naming channel.
type FieldFunc func(msg any) *Field

const tenantFieldName protoreflect.Name = "tenant_id"

// maxFieldDepth bounds how deep ProtoTenantField descends into set
// message-typed fields: the top-level request and one nested object
// (`data`, `intent`, ...), which is how every proto in the platform shapes it.
const maxFieldDepth = 2

// ProtoTenantField is the default FieldFunc. It finds a singular string
// field named tenant_id on the message itself or on any populated
// message-typed field one level down.
func ProtoTenantField(msg any) *Field {
	pm, ok := msg.(proto.Message)
	if !ok || pm == nil {
		return nil
	}
	return reflectTenantField(pm.ProtoReflect(), maxFieldDepth)
}

func reflectTenantField(m protoreflect.Message, depth int) *Field {
	if depth == 0 || m == nil || !m.IsValid() {
		return nil
	}
	fields := m.Descriptor().Fields()
	if fd := fields.ByName(tenantFieldName); fd != nil && isSingularString(fd) {
		return &Field{
			Get: func() string { return m.Get(fd).String() },
			Set: func(v string) { m.Set(fd, protoreflect.ValueOfString(v)) },
		}
	}
	for i := range fields.Len() {
		fd := fields.Get(i)
		if fd.Kind() != protoreflect.MessageKind || fd.IsList() || fd.IsMap() || !m.Has(fd) {
			continue
		}
		if nested := reflectTenantField(m.Mutable(fd).Message(), depth-1); nested != nil {
			return nested
		}
	}
	return nil
}

func isSingularString(fd protoreflect.FieldDescriptor) bool {
	return fd.Kind() == protoreflect.StringKind && !fd.IsList() && !fd.IsMap()
}
