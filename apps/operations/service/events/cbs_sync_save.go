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

package events

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/v2/events"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
)

const CBSSyncRecordSaveEvent = "cbs_sync_record.save"

// NewCBSSyncRecordSave creates a new CBS sync record save event handler.
func NewCBSSyncRecordSave(_ context.Context, repo repository.CBSSyncRecordRepository) events.EventI {
	return &eventHandler[*models.CBSSyncRecord]{
		name:    CBSSyncRecordSaveEvent,
		factory: func() *models.CBSSyncRecord { return &models.CBSSyncRecord{} },
		validate: func(_ context.Context, cs *models.CBSSyncRecord) error {
			if cs.OwnerID == "" {
				return errors.New("owner_id is required")
			}
			return nil
		},
		repo: repo,
	}
}
