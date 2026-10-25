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

import "testing"

// The tier's rate reaches loans as the decimal percentage its API reads.
func TestBasisPointsToPercent(t *testing.T) {
	for bp, want := range map[int64]string{2400: "24.00", 2250: "22.50", 5: "0.05", 0: "", -1: ""} {
		if got := basisPointsToPercent(bp); got != want {
			t.Errorf("basisPointsToPercent(%d) = %q, want %q", bp, got, want)
		}
	}
}
