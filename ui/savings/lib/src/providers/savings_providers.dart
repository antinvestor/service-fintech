import 'dart:math';

import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'savings_transport_provider.dart';

// ---------------------------------------------------------------------------
// Idempotency helper (local)
// ---------------------------------------------------------------------------

String _generateIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

// ---------------------------------------------------------------------------
// Savings Products
// ---------------------------------------------------------------------------

/// Search savings products by query string.
final savingsProductListProvider =
    FutureProvider.family<List<SavingsProductObject>, String>(
  (ref, query) async {
    final client = ref.watch(savingsServiceClientProvider);
    final request = SavingsProductSearchRequest(
      query: query,
      cursor: PageCursor(limit: 50),
    );
    return collectStream(
      client.savingsProductSearch(request),
      extract: (response) => response.data,
    );
  },
);

/// Notifier for savings product mutations.
class SavingsProductNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SavingsServiceClient get _client => ref.read(savingsServiceClientProvider);

  Future<SavingsProductObject> save(SavingsProductObject product) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.savingsProductSave(
        SavingsProductSaveRequest(data: product),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(savingsProductListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final savingsProductNotifierProvider =
    NotifierProvider<SavingsProductNotifier, AsyncValue<void>>(
  SavingsProductNotifier.new,
);

// ---------------------------------------------------------------------------
// Savings Accounts
// ---------------------------------------------------------------------------

/// Search savings accounts by query string, optionally filtered by owner.
final savingsAccountListProvider =
    FutureProvider.family<List<SavingsAccountObject>, ({String query, String ownerId})>(
  (ref, params) async {
    final client = ref.watch(savingsServiceClientProvider);
    final request = SavingsAccountSearchRequest(
      query: params.query,
      cursor: PageCursor(limit: 50),
    );
    if (params.ownerId.isNotEmpty) {
      request.ownerId = params.ownerId;
    }
    return collectStream(
      client.savingsAccountSearch(request),
      extract: (response) => response.data,
    );
  },
);

/// Get a single savings account by ID.
final savingsAccountDetailProvider =
    FutureProvider.family<SavingsAccountObject, String>(
  (ref, id) async {
    final client = ref.watch(savingsServiceClientProvider);
    final response = await client.savingsAccountGet(
      SavingsAccountGetRequest(id: id),
    );
    return response.data;
  },
);

/// Get the balance for a savings account.
final savingsBalanceProvider =
    FutureProvider.family<SavingsBalanceObject, String>(
  (ref, accountId) async {
    final client = ref.watch(savingsServiceClientProvider);
    final response = await client.savingsBalanceGet(
      SavingsBalanceGetRequest(savingsAccountId: accountId),
    );
    return response.data;
  },
);

/// Notifier for savings account mutations.
class SavingsAccountNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SavingsServiceClient get _client => ref.read(savingsServiceClientProvider);

  Future<SavingsAccountObject> create(SavingsAccountObject account) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.savingsAccountCreate(
        SavingsAccountCreateRequest(data: account),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(savingsAccountListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> freeze(String id) async {
    state = const AsyncValue.loading();
    try {
      await _client.savingsAccountFreeze(SavingsAccountFreezeRequest(id: id));
      state = const AsyncValue.data(null);
      ref.invalidate(savingsAccountListProvider);
      ref.invalidate(savingsAccountDetailProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> close(String id) async {
    state = const AsyncValue.loading();
    try {
      await _client.savingsAccountClose(SavingsAccountCloseRequest(id: id));
      state = const AsyncValue.data(null);
      ref.invalidate(savingsAccountListProvider);
      ref.invalidate(savingsAccountDetailProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final savingsAccountNotifierProvider =
    NotifierProvider<SavingsAccountNotifier, AsyncValue<void>>(
  SavingsAccountNotifier.new,
);

// ---------------------------------------------------------------------------
// Deposits
// ---------------------------------------------------------------------------

/// List deposits for a savings account.
final depositListProvider =
    FutureProvider.family<List<DepositObject>, String>(
  (ref, savingsAccountId) async {
    final client = ref.watch(savingsServiceClientProvider);
    final request = DepositSearchRequest(
      savingsAccountId: savingsAccountId,
      cursor: PageCursor(limit: 50),
    );
    return collectStream(
      client.depositSearch(request),
      extract: (response) => response.data,
    );
  },
);

/// Notifier for deposit mutations.
class DepositNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SavingsServiceClient get _client => ref.read(savingsServiceClientProvider);

  Future<DepositObject> record({
    required String savingsAccountId,
    required String amount,
    required String currencyCode,
    String paymentReference = '',
    String channel = '',
    String payerReference = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = DepositRecordRequest(
        savingsAccountId: savingsAccountId,
        paymentReference: paymentReference,
        channel: channel,
        payerReference: payerReference,
        idempotencyKey: _generateIdempotencyKey(),
      );
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await _client.depositRecord(req);
      state = const AsyncValue.data(null);
      ref.invalidate(depositListProvider);
      ref.invalidate(savingsBalanceProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final depositNotifierProvider =
    NotifierProvider<DepositNotifier, AsyncValue<void>>(
  DepositNotifier.new,
);

// ---------------------------------------------------------------------------
// Withdrawals
// ---------------------------------------------------------------------------

/// List withdrawals for a savings account.
final withdrawalListProvider =
    FutureProvider.family<List<WithdrawalObject>, String>(
  (ref, savingsAccountId) async {
    final client = ref.watch(savingsServiceClientProvider);
    final request = WithdrawalSearchRequest(
      savingsAccountId: savingsAccountId,
      cursor: PageCursor(limit: 50),
    );
    return collectStream(
      client.withdrawalSearch(request),
      extract: (response) => response.data,
    );
  },
);

/// Notifier for withdrawal mutations.
class WithdrawalNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SavingsServiceClient get _client => ref.read(savingsServiceClientProvider);

  Future<WithdrawalObject> request({
    required String savingsAccountId,
    required String amount,
    required String currencyCode,
    String channel = '',
    String recipientReference = '',
    String reason = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = WithdrawalRequestRequest(
        savingsAccountId: savingsAccountId,
        channel: channel,
        recipientReference: recipientReference,
        reason: reason,
        idempotencyKey: _generateIdempotencyKey(),
      );
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await _client.withdrawalRequest(req);
      state = const AsyncValue.data(null);
      ref.invalidate(withdrawalListProvider);
      ref.invalidate(savingsBalanceProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<WithdrawalObject> approve(String id) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.withdrawalApprove(
        WithdrawalApproveRequest(id: id),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(withdrawalListProvider);
      ref.invalidate(savingsBalanceProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final withdrawalNotifierProvider =
    NotifierProvider<WithdrawalNotifier, AsyncValue<void>>(
  WithdrawalNotifier.new,
);
