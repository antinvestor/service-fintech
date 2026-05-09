import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'funding_transport_provider.dart';

// ---------------------------------------------------------------------------
// Investor Accounts
// ---------------------------------------------------------------------------

/// List investor accounts, optionally filtered by investor ID.
final investorAccountListProvider =
    FutureProvider.family<List<InvestorAccountObject>, ({String investorId})>(
  (ref, params) async {
    final client = ref.watch(fundingServiceClientProvider);
    final request = InvestorAccountSearchRequest(
      cursor: PageCursor(limit: 50),
    );
    if (params.investorId.isNotEmpty) {
      request.investorId = params.investorId;
    }
    return collectStream(
      client.investorAccountSearch(request),
      extract: (response) => response.data,
    );
  },
);

/// Get a single investor account by ID.
final investorAccountDetailProvider =
    FutureProvider.family<InvestorAccountObject, String>(
  (ref, id) async {
    final client = ref.watch(fundingServiceClientProvider);
    final response = await client.investorAccountGet(
      InvestorAccountGetRequest(id: id),
    );
    return response.data;
  },
);

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

  Future<InvestorAccountObject> deposit({
    required String accountId,
    required String amount,
    required String currencyCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = InvestorDepositRequest(accountId: accountId);
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await _client.investorDeposit(req);
      state = const AsyncValue.data(null);
      ref.invalidate(investorAccountDetailProvider(accountId));
      ref.invalidate(investorAccountListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<InvestorAccountObject> withdraw({
    required String accountId,
    required String amount,
    required String currencyCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = InvestorWithdrawRequest(accountId: accountId);
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await _client.investorWithdraw(req);
      state = const AsyncValue.data(null);
      ref.invalidate(investorAccountDetailProvider(accountId));
      ref.invalidate(investorAccountListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<FundLoanResponse> fundLoan({
    required String loanRequestId,
    String? accountId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.fundLoan(
        FundLoanRequest(loanRequestId: loanRequestId),
      );
      state = const AsyncValue.data(null);
      if (accountId != null) {
        ref.invalidate(investorAccountDetailProvider(accountId));
      }
      ref.invalidate(investorAccountListProvider);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> absorbLoss({
    required String loanRequestId,
    required dynamic amount,
    String? accountId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _client.absorbLoss(
        AbsorbLossRequest(loanRequestId: loanRequestId, amount: amount),
      );
      state = const AsyncValue.data(null);
      if (accountId != null) {
        ref.invalidate(investorAccountDetailProvider(accountId));
      }
      ref.invalidate(investorAccountListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final investorAccountNotifierProvider =
    NotifierProvider<InvestorAccountNotifier, AsyncValue<void>>(
  InvestorAccountNotifier.new,
);
