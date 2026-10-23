import 'package:antinvestor_api_common/antinvestor_api_common.dart' as common;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    as identity;

/// Converts the identity package's STATE to the common package's STATE
/// for compatibility with antinvestor_ui_core widgets (StateBadge, stateLabel).
common.STATE toCommonState(identity.STATE state) {
  return common.STATE.valueOf(state.value) ?? common.STATE.CREATED;
}
