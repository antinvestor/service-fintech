import 'dart:math';

import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'savings_transport_provider.dart';

/// Page size used by every list provider in this package.
const savingsPageSize = 50;

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

// ---------------------------------------------------------------------------
// Savings Products
// ---------------------------------------------------------------------------

/// Search savings products by free-text query, scoped to an organization.
final savingsProductListProvider =
    FutureProvider.family<
      List<SavingsProductObject>,
      ({String query, String organizationId})
    >((ref, params) async {
      final client = ref.watch(savingsServiceClientProvider);
      final request = SavingsProductSearchRequest(
        query: params.query,
        cursor: PageCursor(limit: savingsPageSize),
      );
      if (params.organizationId.isNotEmpty) {
        request.organizationId = params.organizationId;
      }
      return collectStream(
        client.savingsProductSearch(request),
        extract: (response) => response.data,
      );
    });

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

/// Search savings accounts, optionally narrowed by owner and organization.
final savingsAccountListProvider =
    FutureProvider.family<
      List<SavingsAccountObject>,
      ({String query, String ownerId, String organizationId})
    >((ref, params) async {
      final client = ref.watch(savingsServiceClientProvider);
      final request = SavingsAccountSearchRequest(
        query: params.query,
        cursor: PageCursor(limit: savingsPageSize),
      );
      if (params.ownerId.isNotEmpty) {
        request.ownerId = params.ownerId;
      }
      if (params.organizationId.isNotEmpty) {
        request.organizationId = params.organizationId;
      }
      return collectStream(
        client.savingsAccountSearch(request),
        extract: (response) => response.data,
      );
    });

/// Get a single savings account by ID.
final savingsAccountDetailProvider =
    FutureProvider.family<SavingsAccountObject, String>((ref, id) async {
      final client = ref.watch(savingsServiceClientProvider);
      final response = await client.savingsAccountGet(
        SavingsAccountGetRequest(id: id),
      );
      return response.data;
    });

/// Get the balance for a savings account.
final savingsBalanceProvider =
    FutureProvider.family<SavingsBalanceObject, String>((ref, accountId) async {
      final client = ref.watch(savingsServiceClientProvider);
      final response = await client.savingsBalanceGet(
        SavingsBalanceGetRequest(savingsAccountId: accountId),
      );
      return response.data;
    });

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

  Future<SavingsAccountObject> freeze(String id, String reason) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.savingsAccountFreeze(
        SavingsAccountFreezeRequest(id: id, reason: reason),
      );
      state = const AsyncValue.data(null);
      _invalidateAccount(id);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<SavingsAccountObject> close(String id, String reason) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.savingsAccountClose(
        SavingsAccountCloseRequest(id: id, reason: reason),
      );
      state = const AsyncValue.data(null);
      _invalidateAccount(id);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _invalidateAccount(String id) {
    ref.invalidate(savingsAccountListProvider);
    ref.invalidate(savingsAccountDetailProvider(id));
    ref.invalidate(savingsBalanceProvider(id));
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
final depositListProvider = FutureProvider.family<List<DepositObject>, String>((
  ref,
  savingsAccountId,
) async {
  final client = ref.watch(savingsServiceClientProvider);
  final request = DepositSearchRequest(
    savingsAccountId: savingsAccountId,
    cursor: PageCursor(limit: savingsPageSize),
  );
  return collectStream(
    client.depositSearch(request),
    extract: (response) => response.data,
  );
});

// ---------------------------------------------------------------------------
// Withdrawals
// ---------------------------------------------------------------------------

/// List withdrawals for a savings account.
final withdrawalListProvider =
    FutureProvider.family<List<WithdrawalObject>, String>((
      ref,
      savingsAccountId,
    ) async {
      final client = ref.watch(savingsServiceClientProvider);
      final request = WithdrawalSearchRequest(
        savingsAccountId: savingsAccountId,
        cursor: PageCursor(limit: savingsPageSize),
      );
      return collectStream(
        client.withdrawalSearch(request),
        extract: (response) => response.data,
      );
    });

/// Notifier for withdrawal mutations.
class WithdrawalNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SavingsServiceClient get _client => ref.read(savingsServiceClientProvider);

  /// Requests a withdrawal. [idempotencyKey] must be generated once per user
  /// intent so a retry does not place a second hold on the member's funds.
  Future<WithdrawalObject> request({
    required String savingsAccountId,
    required String amount,
    required String currencyCode,
    required String idempotencyKey,
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
        idempotencyKey: idempotencyKey,
      );
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await _client.withdrawalRequest(req);
      state = const AsyncValue.data(null);
      _invalidate(savingsAccountId);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<WithdrawalObject> approve(String id, String savingsAccountId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.withdrawalApprove(
        WithdrawalApproveRequest(id: id),
      );
      state = const AsyncValue.data(null);
      _invalidate(savingsAccountId);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<WithdrawalObject> cancel(
    String id,
    String savingsAccountId,
    String reason,
  ) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.withdrawalCancel(
        WithdrawalCancelRequest(id: id, reason: reason),
      );
      state = const AsyncValue.data(null);
      _invalidate(savingsAccountId);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _invalidate(String savingsAccountId) {
    ref.invalidate(withdrawalListProvider(savingsAccountId));
    ref.invalidate(savingsBalanceProvider(savingsAccountId));
    ref.invalidate(pendingWithdrawalQueueProvider);
  }
}

final withdrawalNotifierProvider =
    NotifierProvider<WithdrawalNotifier, AsyncValue<void>>(
      WithdrawalNotifier.new,
    );

// ---------------------------------------------------------------------------
// Interest accruals & statement
// ---------------------------------------------------------------------------

/// List interest accruals for a savings account.
final interestAccrualListProvider =
    FutureProvider.family<List<InterestAccrualObject>, String>((
      ref,
      savingsAccountId,
    ) async {
      final client = ref.watch(savingsServiceClientProvider);
      final request = InterestAccrualSearchRequest(
        savingsAccountId: savingsAccountId,
        cursor: PageCursor(limit: savingsPageSize),
      );
      return collectStream(
        client.interestAccrualSearch(request),
        extract: (response) => response.data,
      );
    });

/// A withdrawal awaiting approval, paired with the account it draws on.
typedef PendingWithdrawal = ({
  SavingsAccountObject account,
  WithdrawalObject withdrawal,
});

/// Pending withdrawals across every account in an organization, oldest first.
///
/// `WithdrawalSearch` is scoped to one account on the current contract, so
/// the queue lists the organization's accounts and fans out one status-
/// filtered search per open account. Closed accounts cannot hold a pending
/// withdrawal and are skipped.
final pendingWithdrawalQueueProvider =
    FutureProvider.family<List<PendingWithdrawal>, String>((
      ref,
      organizationId,
    ) async {
      final client = ref.watch(savingsServiceClientProvider);
      final accountRequest = SavingsAccountSearchRequest(
        cursor: PageCursor(limit: savingsPageSize),
      );
      if (organizationId.isNotEmpty) {
        accountRequest.organizationId = organizationId;
      }
      final accounts = await collectStream(
        client.savingsAccountSearch(accountRequest),
        extract: (response) => response.data,
      );

      final open = accounts.where(
        (a) => a.status != SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_CLOSED,
      );
      final perAccount = await Future.wait(
        open.map((account) async {
          final withdrawals = await collectStream(
            client.withdrawalSearch(
              WithdrawalSearchRequest(
                savingsAccountId: account.id,
                status: WithdrawalStatus.WITHDRAWAL_STATUS_PENDING,
                cursor: PageCursor(limit: savingsPageSize),
              ),
            ),
            extract: (response) => response.data,
          );
          return [
            for (final w in withdrawals) (account: account, withdrawal: w),
          ];
        }),
      );
      return perAccount.expand((e) => e).toList(growable: false);
    });

/// Fetch the statement for a savings account. Both dates are optional; the
/// server defaults the window when they are omitted.
final savingsStatementProvider =
    FutureProvider.family<
      SavingsStatementResponse,
      ({String accountId, String fromDate, String toDate})
    >((ref, params) async {
      final client = ref.watch(savingsServiceClientProvider);
      return client.savingsStatement(
        SavingsStatementRequest(
          savingsAccountId: params.accountId,
          fromDate: params.fromDate,
          toDate: params.toDate,
        ),
      );
    });
