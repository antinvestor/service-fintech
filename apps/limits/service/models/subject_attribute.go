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

package models

import (
	"time"

	"github.com/pitabwire/frame/v2/data"
	"gorm.io/datatypes"
)

// SubjectAttributeSnapshot caches a subject's identity-side attributes
// (KYC tier, region, risk score, etc.) for fast policy predicate evaluation.
// Refreshed by the AttributeResolver and invalidated by identity events.
type SubjectAttributeSnapshot struct {
	data.BaseModel `gorm:"embedded"`

	SubjectType Subject        `gorm:"column:subject_type;type:varchar(32);not null"`
	SubjectID   string         `gorm:"column:subject_id;type:varchar(50);not null"`
	Attributes  datatypes.JSON `gorm:"column:attributes;type:jsonb;not null"`
	FetchedAt   time.Time      `gorm:"column:fetched_at;type:timestamptz;not null"`
}

func (SubjectAttributeSnapshot) TableName() string { return "limits_subject_attributes" }
