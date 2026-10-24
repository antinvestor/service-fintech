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

import 'package:antinvestor_api_limits/antinvestor_api_limits.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _limitsUrl = String.fromEnvironment(
  'LIMITS_URL',
  defaultValue: 'https://api.antinvestor.com/limits',
);

final limitsTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _limitsUrl);
});

/// Runtime client (Check/Reserve/Commit/Release/Reverse).
final limitsServiceClientProvider = Provider<LimitsServiceClient>((ref) {
  final transport = ref.watch(limitsTransportProvider);
  return LimitsServiceClient(transport);
});

/// Admin client (Policy CRUD + Approvals + Ledger + Audit).
final limitsAdminServiceClientProvider = Provider<LimitsAdminServiceClient>((
  ref,
) {
  final transport = ref.watch(limitsTransportProvider);
  return LimitsAdminServiceClient(transport);
});
