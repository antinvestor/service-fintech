//
//  Generated code. Do not modify.
//  source: savings/v1/savings.proto
//

import "package:connectrpc/connect.dart" as connect;
import "savings.pb.dart" as savingsv1savings;

/// SavingsService manages savings products, accounts, deposits, withdrawals,
/// and interest accruals.
/// All RPCs require authentication via Bearer token.
abstract final class SavingsService {
  /// Fully-qualified name of the SavingsService service.
  static const name = 'savings.v1.SavingsService';

  /// SavingsProductSave creates or updates a savings product.
  static const savingsProductSave = connect.Spec(
    '/$name/SavingsProductSave',
    connect.StreamType.unary,
    savingsv1savings.SavingsProductSaveRequest.new,
    savingsv1savings.SavingsProductSaveResponse.new,
  );

  /// SavingsProductGet retrieves a savings product by its ID.
  static const savingsProductGet = connect.Spec(
    '/$name/SavingsProductGet',
    connect.StreamType.unary,
    savingsv1savings.SavingsProductGetRequest.new,
    savingsv1savings.SavingsProductGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SavingsProductSearch finds savings products matching search criteria.
  static const savingsProductSearch = connect.Spec(
    '/$name/SavingsProductSearch',
    connect.StreamType.server,
    savingsv1savings.SavingsProductSearchRequest.new,
    savingsv1savings.SavingsProductSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SavingsAccountCreate creates a new savings account.
  static const savingsAccountCreate = connect.Spec(
    '/$name/SavingsAccountCreate',
    connect.StreamType.unary,
    savingsv1savings.SavingsAccountCreateRequest.new,
    savingsv1savings.SavingsAccountCreateResponse.new,
  );

  /// SavingsAccountGet retrieves a savings account by its ID.
  static const savingsAccountGet = connect.Spec(
    '/$name/SavingsAccountGet',
    connect.StreamType.unary,
    savingsv1savings.SavingsAccountGetRequest.new,
    savingsv1savings.SavingsAccountGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SavingsAccountSearch finds savings accounts matching search criteria.
  static const savingsAccountSearch = connect.Spec(
    '/$name/SavingsAccountSearch',
    connect.StreamType.server,
    savingsv1savings.SavingsAccountSearchRequest.new,
    savingsv1savings.SavingsAccountSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SavingsAccountFreeze freezes a savings account.
  static const savingsAccountFreeze = connect.Spec(
    '/$name/SavingsAccountFreeze',
    connect.StreamType.unary,
    savingsv1savings.SavingsAccountFreezeRequest.new,
    savingsv1savings.SavingsAccountFreezeResponse.new,
  );

  /// SavingsAccountClose closes a savings account.
  static const savingsAccountClose = connect.Spec(
    '/$name/SavingsAccountClose',
    connect.StreamType.unary,
    savingsv1savings.SavingsAccountCloseRequest.new,
    savingsv1savings.SavingsAccountCloseResponse.new,
  );

  /// DepositRecord records a deposit into a savings account.
  static const depositRecord = connect.Spec(
    '/$name/DepositRecord',
    connect.StreamType.unary,
    savingsv1savings.DepositRecordRequest.new,
    savingsv1savings.DepositRecordResponse.new,
  );

  /// DepositGet retrieves a deposit by its ID.
  static const depositGet = connect.Spec(
    '/$name/DepositGet',
    connect.StreamType.unary,
    savingsv1savings.DepositGetRequest.new,
    savingsv1savings.DepositGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// DepositSearch finds deposits for a savings account.
  static const depositSearch = connect.Spec(
    '/$name/DepositSearch',
    connect.StreamType.server,
    savingsv1savings.DepositSearchRequest.new,
    savingsv1savings.DepositSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// WithdrawalRequest requests a withdrawal from a savings account.
  static const withdrawalRequest = connect.Spec(
    '/$name/WithdrawalRequest',
    connect.StreamType.unary,
    savingsv1savings.WithdrawalRequestRequest.new,
    savingsv1savings.WithdrawalRequestResponse.new,
  );

  /// WithdrawalApprove approves a pending withdrawal.
  static const withdrawalApprove = connect.Spec(
    '/$name/WithdrawalApprove',
    connect.StreamType.unary,
    savingsv1savings.WithdrawalApproveRequest.new,
    savingsv1savings.WithdrawalApproveResponse.new,
  );

  /// WithdrawalCancel rejects a pending withdrawal and releases the reserved balance.
  static const withdrawalCancel = connect.Spec(
    '/$name/WithdrawalCancel',
    connect.StreamType.unary,
    savingsv1savings.WithdrawalCancelRequest.new,
    savingsv1savings.WithdrawalCancelResponse.new,
  );

  /// WithdrawalGet retrieves a withdrawal by its ID.
  static const withdrawalGet = connect.Spec(
    '/$name/WithdrawalGet',
    connect.StreamType.unary,
    savingsv1savings.WithdrawalGetRequest.new,
    savingsv1savings.WithdrawalGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// WithdrawalSearch finds withdrawals for a savings account.
  static const withdrawalSearch = connect.Spec(
    '/$name/WithdrawalSearch',
    connect.StreamType.server,
    savingsv1savings.WithdrawalSearchRequest.new,
    savingsv1savings.WithdrawalSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InterestAccrualGet retrieves an interest accrual by its ID.
  static const interestAccrualGet = connect.Spec(
    '/$name/InterestAccrualGet',
    connect.StreamType.unary,
    savingsv1savings.InterestAccrualGetRequest.new,
    savingsv1savings.InterestAccrualGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InterestAccrualSearch finds interest accruals for a savings account.
  static const interestAccrualSearch = connect.Spec(
    '/$name/InterestAccrualSearch',
    connect.StreamType.server,
    savingsv1savings.InterestAccrualSearchRequest.new,
    savingsv1savings.InterestAccrualSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SavingsBalanceGet retrieves the current balance of a savings account.
  static const savingsBalanceGet = connect.Spec(
    '/$name/SavingsBalanceGet',
    connect.StreamType.unary,
    savingsv1savings.SavingsBalanceGetRequest.new,
    savingsv1savings.SavingsBalanceGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SavingsStatement generates a savings statement for a date range.
  static const savingsStatement = connect.Spec(
    '/$name/SavingsStatement',
    connect.StreamType.unary,
    savingsv1savings.SavingsStatementRequest.new,
    savingsv1savings.SavingsStatementResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// PayoutFailedApply undoes this service's record of a payout the payment
  /// rail failed after accepting it. Only operations calls it.
  static const payoutFailedApply = connect.Spec(
    '/$name/PayoutFailedApply',
    connect.StreamType.unary,
    savingsv1savings.PayoutFailedApplyRequest.new,
    savingsv1savings.PayoutFailedApplyResponse.new,
  );

  /// SavingsJobRun runs one batch of a periodic job. Called by the platform
  /// scheduler (trustage); nothing in the service runs on a timer.
  static const savingsJobRun = connect.Spec(
    '/$name/SavingsJobRun',
    connect.StreamType.unary,
    savingsv1savings.SavingsJobRunRequest.new,
    savingsv1savings.SavingsJobRunResponse.new,
  );
}
