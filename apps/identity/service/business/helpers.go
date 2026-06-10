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
	"context"

	"github.com/pitabwire/frame/workerpool"
)

// workerpoolConsumeStream wraps workerpool.ConsumeResultStream for use in business methods.
func workerpoolConsumeStream[T any](
	ctx context.Context,
	pipe workerpool.JobResultPipe[[]T],
	consumer func(batch []T) error,
) error {
	return workerpool.ConsumeResultStream(ctx, pipe, func(res []T) error {
		return consumer(res)
	})
}

// searchableTSQuery is the GORM map-key predicate used for full-text search
// against the generated "searchable" tsvector column.
const searchableTSQuery = "searchable @@ websearch_to_tsquery( 'english', ?) "
