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
	"strings"
	"testing"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

func TestClassifyFileFieldValue(t *testing.T) {
	t.Parallel()

	longBase64 := strings.Repeat("QUJD", 100) + "=="
	longProse := strings.Repeat("the quick brown fox jumps over the lazy dog ", 8)
	require.GreaterOrEqual(t, len(longProse), 256, "the prose fixture must clear the base64 length floor")

	cases := []struct {
		name    string
		value   any
		wantURI string
		want    fileValueKind
	}{
		{
			name:    "https content uri is accepted",
			value:   "https://files.example.com/v1/media/download/abc",
			wantURI: "https://files.example.com/v1/media/download/abc",
			want:    fileValueURI,
		},
		{
			name:    "scheme is matched case insensitively",
			value:   "HTTPS://files.example.com/x",
			wantURI: "HTTPS://files.example.com/x",
			want:    fileValueURI,
		},
		{
			name:    "surrounding whitespace is trimmed",
			value:   "  https://files.example.com/x \n",
			wantURI: "https://files.example.com/x",
			want:    fileValueURI,
		},
		{name: "http is not on the allowlist", value: "http://files.example.com/x", want: fileValueInvalid},
		{name: "javascript scheme is refused", value: "javascript:alert(1)", want: fileValueInvalid},
		{name: "file scheme is refused", value: "file:///etc/passwd", want: fileValueInvalid},
		{name: "ftp scheme is refused", value: "ftp://files.example.com/x", want: fileValueInvalid},
		{name: "userinfo is refused", value: "https://user:secret@files.example.com/x", want: fileValueInvalid},
		{name: "empty host is refused", value: "https:///x", want: fileValueInvalid},
		{name: "relative path is refused", value: "/v1/media/download/abc", want: fileValueInvalid},
		{name: "empty string is refused", value: "   ", want: fileValueInvalid},
		{name: "unparseable uri is refused", value: "https://files.example.com/%zz", want: fileValueInvalid},
		{name: "data uri is inline", value: "data:image/png;base64,iVBORw0KGgo=", want: fileValueInline},
		{name: "data uri scheme is case insensitive", value: "DATA:image/png;base64,AAAA", want: fileValueInline},
		{name: "long base64 payload is inline", value: longBase64, want: fileValueInline},
		{name: "long url-safe base64 payload is inline", value: strings.Repeat("ab-_", 70), want: fileValueInline},
		{
			name:  "long prose is invalid, not misread as base64",
			value: longProse,
			want:  fileValueInvalid,
		},
		{name: "short garbage is invalid", value: "not a uri", want: fileValueInvalid},
		{
			name:  "inline file object is inline",
			value: map[string]any{"_type": "file", "bytes": "AAAA"},
			want:  fileValueInline,
		},
		{
			name:    "file_ref object with https uri is accepted",
			value:   map[string]any{"_type": "file_ref", "content_uri": "https://files.example.com/x"},
			wantURI: "https://files.example.com/x",
			want:    fileValueURI,
		},
		{
			name:  "file_ref object with javascript uri is refused",
			value: map[string]any{"_type": "file_ref", "content_uri": "javascript:alert(1)"},
			want:  fileValueInvalid,
		},
		{
			name:  "file_ref object without a uri is refused",
			value: map[string]any{"_type": "file_ref"},
			want:  fileValueInvalid,
		},
		{name: "object without file marker carries no file", value: map[string]any{"lat": 1.0}, want: fileValueAbsent},
		{name: "numbers carry no file", value: 42, want: fileValueAbsent},
		{name: "nil carries no file", value: nil, want: fileValueAbsent},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			uri, kind := classifyFileFieldValue(tc.value)
			require.Equal(t, tc.want, kind)
			require.Equal(t, tc.wantURI, uri)
		})
	}
}

// TestFormSubmissionSaveFileFieldOutcomes walks the classification through
// Save against a published template so the error each class maps to is
// pinned at the API boundary, and FileRefs is populated for accepted URIs.
func (s *approvalWorkflowSuite) TestFormSubmissionSaveFileFieldOutcomes() {
	env := s.newEnv()
	submissions := NewFormSubmissionBusiness(env.ctx, env.eventsMan, env.formSubmissions, env.formTemplateRepo)

	template := &models.FormTemplate{
		Name:            "ID Capture",
		Status:          int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED),
		TemplateVersion: 2,
		EntityType:      "client",
		Fields: data.JSONMap{"items": []any{
			map[string]any{
				"key":        "id_front_photo",
				"label":      "ID front",
				"field_type": float64(identityv1.FormFieldType_FORM_FIELD_TYPE_PHOTO),
				"required":   true,
			},
			map[string]any{
				"key":        "notes",
				"label":      "Notes",
				"field_type": float64(identityv1.FormFieldType_FORM_FIELD_TYPE_TEXT),
				"required":   false,
			},
		}},
	}
	template.GenID(env.ctx)
	s.Require().NoError(env.formTemplateRepo.Create(env.ctx, template))

	longProse := strings.Repeat("applicant declined to provide the document today ", 8)

	cases := []struct {
		name    string
		photo   any
		wantErr error
	}{
		{name: "https uri is stored as a file ref", photo: "https://files.example.com/media/1"},
		{
			name:    "javascript uri is rejected as invalid",
			photo:   "javascript:alert(1)",
			wantErr: ErrFormSubmissionInvalidFileURI,
		},
		{
			name:    "http uri is rejected as invalid",
			photo:   "http://files.example.com/media/1",
			wantErr: ErrFormSubmissionInvalidFileURI,
		},
		{
			name:    "long prose is rejected as invalid, not inline",
			photo:   longProse,
			wantErr: ErrFormSubmissionInvalidFileURI,
		},
		{
			name:    "data uri is rejected as inline",
			photo:   "data:image/png;base64,AAAA",
			wantErr: ErrFormSubmissionInlineFileData,
		},
	}

	for _, tc := range cases {
		s.Run(tc.name, func() {
			payload, err := structpb.NewStruct(map[string]any{
				"id_front_photo": tc.photo,
				"notes":          "ok",
			})
			s.Require().NoError(err)

			saved, saveErr := submissions.Save(env.ctx, &identityv1.FormSubmissionObject{
				EntityId:   "client-form-1",
				EntityType: "client",
				TemplateId: template.GetID(),
				Data:       payload,
			})
			if tc.wantErr != nil {
				s.Require().ErrorIs(saveErr, tc.wantErr)
				return
			}
			s.Require().NoError(saveErr)
			s.Require().NotNil(saved)
			s.EqualValues(2, saved.GetTemplateVersion(), "the template version must be stamped at submission")

			stored, getErr := env.formSubmissions.GetByID(env.ctx, saved.GetId())
			s.Require().NoError(getErr)
			s.Equal(tc.photo, stored.FileRefs["id_front_photo"], "accepted URIs must be indexed in FileRefs")
		})
	}
}
