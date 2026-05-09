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

// Bridges proto enum types from service-specific API packages to the
// common types expected by antinvestor_ui_core.
//
// Money is no longer bridged here — antinvestor_ui_core helpers
// (formatMoney, moneyCurrency, setMoneyFields, …) read service-typed
// Money via dynamic dispatch as of ui_core 0.4.0.

import 'package:antinvestor_api_common/antinvestor_api_common.dart' show STATE;

/// Converts any proto STATE enum to the common [STATE] type.
STATE bridgeState(dynamic state) {
  return STATE.valueOf((state as dynamic).value as int) ?? STATE.CREATED;
}
