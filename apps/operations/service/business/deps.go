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

// deps.go defines local interfaces and lightweight data types for cross-domain
// dependencies that lack SDK RPCs. Identity lookups use the SDK client directly;
// stawi period data still uses a local repo interface, wired only in the stawi
// process that owns those tables.

import (
	"context"
	"time"

	"github.com/pitabwire/frame/v3/data"
)

// ---------------------------------------------------------------------------
// Stawi: periods
// ---------------------------------------------------------------------------

// PeriodInfo is a lightweight projection of stawi's Period model.
type PeriodInfo struct {
	data.BaseModel
	EndDate  *time.Time
	Position int32
}

// PeriodReader provides read access to period data.
type PeriodReader interface {
	GetCurrentByGroupID(ctx context.Context, groupID string) (*PeriodInfo, error)
}
