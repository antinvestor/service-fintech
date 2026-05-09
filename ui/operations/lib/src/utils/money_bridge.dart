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
