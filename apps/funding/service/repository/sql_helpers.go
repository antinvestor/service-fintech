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

package repository

import "gorm.io/gorm"

// gormNow and gormVersionIncrement keep the BaseModel bookkeeping columns
// correct on the map-based UPDATEs this package uses, which bypass GORM's
// struct hooks.
func gormNow() any { return gorm.Expr("now()") }

func gormVersionIncrement() any { return gorm.Expr("version + 1") }
