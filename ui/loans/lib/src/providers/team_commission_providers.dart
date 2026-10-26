import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

/// A team's commission balances, one per currency.
final teamCommissionProvider =
    FutureProvider.family<List<TeamCommissionObject>, String>((
      ref,
      teamId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      return collectStream(
        client.teamCommissionSearch(
          TeamCommissionSearchRequest(
            teamId: teamId,
            cursor: PageCursor(limit: 50),
          ),
        ),
        extract: (response) => response.data,
      );
    });

/// A team's commission payouts, newest first.
final teamCommissionPayoutsProvider =
    FutureProvider.family<List<TeamCommissionPayoutObject>, String>((
      ref,
      teamId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      return collectStream(
        client.teamCommissionPayoutSearch(
          TeamCommissionPayoutSearchRequest(
            teamId: teamId,
            cursor: PageCursor(limit: 50),
          ),
        ),
        extract: (response) => response.data,
      );
    });
