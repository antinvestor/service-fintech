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

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The limits permissions the signed-in operator holds, mirroring the OPL
/// permits declared for `service_limits`.
///
/// The screens gate their mutating affordances on these so an operator is not
/// offered a Save or Delete the server will refuse. This is presentation only:
/// the server re-checks every call.
class LimitsCapabilities {
  /// Whether the operator may create, edit or delete policies.
  final bool policyManage;

  /// Whether the operator may decide approval requests.
  final bool approvalAct;

  const LimitsCapabilities({
    required this.policyManage,
    required this.approvalAct,
  });

  /// Every affordance enabled. The default while the host app has not wired a
  /// capability source; the server remains the authority either way.
  const LimitsCapabilities.all() : policyManage = true, approvalAct = true;

  /// Read-only. Use when the capability service could not answer.
  const LimitsCapabilities.none() : policyManage = false, approvalAct = false;
}

/// The capabilities the limits screens gate on. Host apps override this in
/// their root `ProviderScope` with the operator's resolved permissions:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     limitsCapabilitiesProvider.overrideWithValue(
///       LimitsCapabilities(policyManage: grants.contains('limits_policy_manage'),
///                          approvalAct: grants.contains('limits_approval_act')),
///     ),
///   ],
/// )
/// ```
final limitsCapabilitiesProvider = Provider<LimitsCapabilities>(
  (ref) => const LimitsCapabilities.all(),
);
