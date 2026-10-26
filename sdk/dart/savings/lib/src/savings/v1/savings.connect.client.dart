//
//  Generated code. Do not modify.
//  source: savings/v1/savings.proto
//

import "package:connectrpc/connect.dart" as connect;
import "savings.pb.dart" as savingsv1savings;
import "savings.connect.spec.dart" as specs;

/// SavingsService manages savings products, accounts, deposits, withdrawals,
/// and interest accruals.
/// All RPCs require authentication via Bearer token.
extension type SavingsServiceClient (connect.Transport _transport) {
  /// SavingsProductSave creates or updates a savings product.
  Future<savingsv1savings.SavingsProductSaveResponse> savingsProductSave(
    savingsv1savings.SavingsProductSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsProductSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsProductGet retrieves a savings product by its ID.
  Future<savingsv1savings.SavingsProductGetResponse> savingsProductGet(
    savingsv1savings.SavingsProductGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsProductGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsProductSearch finds savings products matching search criteria.
  Stream<savingsv1savings.SavingsProductSearchResponse> savingsProductSearch(
    savingsv1savings.SavingsProductSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.SavingsService.savingsProductSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsAccountCreate creates a new savings account.
  Future<savingsv1savings.SavingsAccountCreateResponse> savingsAccountCreate(
    savingsv1savings.SavingsAccountCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsAccountCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsAccountGet retrieves a savings account by its ID.
  Future<savingsv1savings.SavingsAccountGetResponse> savingsAccountGet(
    savingsv1savings.SavingsAccountGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsAccountGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsAccountSearch finds savings accounts matching search criteria.
  Stream<savingsv1savings.SavingsAccountSearchResponse> savingsAccountSearch(
    savingsv1savings.SavingsAccountSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.SavingsService.savingsAccountSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsAccountFreeze freezes a savings account.
  Future<savingsv1savings.SavingsAccountFreezeResponse> savingsAccountFreeze(
    savingsv1savings.SavingsAccountFreezeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsAccountFreeze,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsAccountClose closes a savings account.
  Future<savingsv1savings.SavingsAccountCloseResponse> savingsAccountClose(
    savingsv1savings.SavingsAccountCloseRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsAccountClose,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DepositRecord records a deposit into a savings account.
  Future<savingsv1savings.DepositRecordResponse> depositRecord(
    savingsv1savings.DepositRecordRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.depositRecord,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DepositGet retrieves a deposit by its ID.
  Future<savingsv1savings.DepositGetResponse> depositGet(
    savingsv1savings.DepositGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.depositGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DepositSearch finds deposits for a savings account.
  Stream<savingsv1savings.DepositSearchResponse> depositSearch(
    savingsv1savings.DepositSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.SavingsService.depositSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// WithdrawalRequest requests a withdrawal from a savings account.
  Future<savingsv1savings.WithdrawalRequestResponse> withdrawalRequest(
    savingsv1savings.WithdrawalRequestRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.withdrawalRequest,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// WithdrawalApprove approves a pending withdrawal.
  Future<savingsv1savings.WithdrawalApproveResponse> withdrawalApprove(
    savingsv1savings.WithdrawalApproveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.withdrawalApprove,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// WithdrawalCancel rejects a pending withdrawal and releases the reserved balance.
  Future<savingsv1savings.WithdrawalCancelResponse> withdrawalCancel(
    savingsv1savings.WithdrawalCancelRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.withdrawalCancel,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// WithdrawalGet retrieves a withdrawal by its ID.
  Future<savingsv1savings.WithdrawalGetResponse> withdrawalGet(
    savingsv1savings.WithdrawalGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.withdrawalGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// WithdrawalSearch finds withdrawals for a savings account.
  Stream<savingsv1savings.WithdrawalSearchResponse> withdrawalSearch(
    savingsv1savings.WithdrawalSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.SavingsService.withdrawalSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// InterestAccrualGet retrieves an interest accrual by its ID.
  Future<savingsv1savings.InterestAccrualGetResponse> interestAccrualGet(
    savingsv1savings.InterestAccrualGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.interestAccrualGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// InterestAccrualSearch finds interest accruals for a savings account.
  Stream<savingsv1savings.InterestAccrualSearchResponse> interestAccrualSearch(
    savingsv1savings.InterestAccrualSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.SavingsService.interestAccrualSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsBalanceGet retrieves the current balance of a savings account.
  Future<savingsv1savings.SavingsBalanceGetResponse> savingsBalanceGet(
    savingsv1savings.SavingsBalanceGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsBalanceGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsStatement generates a savings statement for a date range.
  Future<savingsv1savings.SavingsStatementResponse> savingsStatement(
    savingsv1savings.SavingsStatementRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsStatement,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PayoutFailedApply undoes this service's record of a payout the payment
  /// rail failed after accepting it. Only operations calls it.
  Future<savingsv1savings.PayoutFailedApplyResponse> payoutFailedApply(
    savingsv1savings.PayoutFailedApplyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.payoutFailedApply,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SavingsJobRun runs one batch of a periodic job. Called by the platform
  /// scheduler (trustage); nothing in the service runs on a timer.
  Future<savingsv1savings.SavingsJobRunResponse> savingsJobRun(
    savingsv1savings.SavingsJobRunRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SavingsService.savingsJobRun,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
