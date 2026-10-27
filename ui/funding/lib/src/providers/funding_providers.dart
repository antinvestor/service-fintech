import 'dart:math';

import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'funding_transport_provider.dart';

/// Page size used by every list provider in this package.
const fundingPageSize = 50;

/// Header the funding service requires on every capital movement.
const idempotencyHeader = 'Idempotency-Key';

/// Generates a fresh idempotency key.
///
/// Call this once per user intent — typically in a dialog's `initState` — and
/// reuse the value across retries. Minting a key per submit turns the user's
/// second tap on a failed request into a second deposit.
String generateIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

Headers _idempotencyHeaders(String key) =>
    Headers()..add(idempotencyHeader, key);

// ---------------------------------------------------------------------------
// Investor Accounts
// ---------------------------------------------------------------------------

/// List investor accounts. Both filters are optional: an empty investor id
/// lists every account the caller may see.
final investorAccountListProvider =
    FutureProvider.family<
      List<InvestorAccountObject>,
      ({String investorId, String currencyCode})
    >((ref, params) async {
      final client = ref.watch(fundingServiceClientProvider);
      final request = InvestorAccountSearchRequest(
        cursor: PageCursor(limit: fundingPageSize),
      );
      if (params.investorId.isNotEmpty) {
        request.investorId = params.investorId;
      }
      if (params.currencyCode.isNotEmpty) {
        request.currencyCode = params.currencyCode;
      }
      return collectStream(
        client.investorAccountSearch(request),
        extract: (response) => response.data,
      );
    });

/// Get a single investor account by ID.
final investorAccountDetailProvider =
    FutureProvider.family<InvestorAccountObject, String>((ref, id) async {
      final client = ref.watch(fundingServiceClientProvider);
      final response = await client.investorAccountGet(
        InvestorAccountGetRequest(id: id),
      );
      return response.data;
    });

/// Notifier for investor account mutations.
class InvestorAccountNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  FundingServiceClient get _client => ref.read(fundingServiceClientProvider);

  Future<InvestorAccountObject> save(InvestorAccountObject account) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.investorAccountSave(
        InvestorAccountSaveRequest(data: account),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(investorAccountListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Withdraws investor capital. [idempotencyKey] must be generated once
  /// per user intent: the server keys the movement on it, and a fresh key on
  /// a retry is a second withdrawal.
  Future<InvestorAccountObject> withdraw({
    required String accountId,
    required String amount,
    required String currencyCode,
    required String idempotencyKey,
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = InvestorWithdrawRequest(accountId: accountId);
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await _client.investorWithdraw(
        req,
        headers: _idempotencyHeaders(idempotencyKey),
      );
      state = const AsyncValue.data(null);
      _invalidate(accountId);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _invalidate(String accountId) {
    ref.invalidate(investorAccountDetailProvider(accountId));
    ref.invalidate(investorAccountListProvider);
  }
}

final investorAccountNotifierProvider =
    NotifierProvider<InvestorAccountNotifier, AsyncValue<void>>(
      InvestorAccountNotifier.new,
    );

/// A statement period: from inclusive, to exclusive.
typedef StatementPeriod = ({String accountId, DateTime from, DateTime to});

/// What moved an investor account's capital over a period.
final investorStatementProvider =
    FutureProvider.family<InvestorStatementResponse, StatementPeriod>((
      ref,
      period,
    ) async {
      final client = ref.watch(fundingServiceClientProvider);
      return client.investorStatement(
        InvestorStatementRequest(
          investorAccountId: period.accountId,
          from: period.from.toUtc().toIso8601String(),
          to: period.to.toUtc().toIso8601String(),
        ),
      );
    });
