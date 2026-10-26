//
//  Generated code. Do not modify.
//  source: loans/v1/loans.proto
//

import "package:connectrpc/connect.dart" as connect;
import "loans.pb.dart" as loansv1loans;

/// LoanManagementService manages active loans, disbursements, repayments,
/// schedules, penalties, restructures, and reconciliation.
/// All RPCs require authentication via Bearer token.
abstract final class LoanManagementService {
  /// Fully-qualified name of the LoanManagementService service.
  static const name = 'loans.v1.LoanManagementService';

  /// LoanProductSave creates or updates a loan product.
  static const loanProductSave = connect.Spec(
    '/$name/LoanProductSave',
    connect.StreamType.unary,
    loansv1loans.LoanProductSaveRequest.new,
    loansv1loans.LoanProductSaveResponse.new,
  );

  /// LoanProductGet retrieves a loan product by its ID.
  static const loanProductGet = connect.Spec(
    '/$name/LoanProductGet',
    connect.StreamType.unary,
    loansv1loans.LoanProductGetRequest.new,
    loansv1loans.LoanProductGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanProductSearch finds loan products matching search criteria.
  static const loanProductSearch = connect.Spec(
    '/$name/LoanProductSearch',
    connect.StreamType.server,
    loansv1loans.LoanProductSearchRequest.new,
    loansv1loans.LoanProductSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanRequestSave creates or updates a loan request. Called by product services
  /// (seed, stawi, etc.) after completing their own acquisition workflows.
  static const loanRequestSave = connect.Spec(
    '/$name/LoanRequestSave',
    connect.StreamType.unary,
    loansv1loans.LoanRequestSaveRequest.new,
    loansv1loans.LoanRequestSaveResponse.new,
  );

  /// LoanRequestGet retrieves a loan request by its ID.
  static const loanRequestGet = connect.Spec(
    '/$name/LoanRequestGet',
    connect.StreamType.unary,
    loansv1loans.LoanRequestGetRequest.new,
    loansv1loans.LoanRequestGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanRequestSearch finds loan requests matching search criteria.
  static const loanRequestSearch = connect.Spec(
    '/$name/LoanRequestSearch',
    connect.StreamType.server,
    loansv1loans.LoanRequestSearchRequest.new,
    loansv1loans.LoanRequestSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanRequestApprove approves a loan request and creates the loan account.
  static const loanRequestApprove = connect.Spec(
    '/$name/LoanRequestApprove',
    connect.StreamType.unary,
    loansv1loans.LoanRequestApproveRequest.new,
    loansv1loans.LoanRequestApproveResponse.new,
  );

  /// LoanRequestReject rejects a loan request with a reason.
  static const loanRequestReject = connect.Spec(
    '/$name/LoanRequestReject',
    connect.StreamType.unary,
    loansv1loans.LoanRequestRejectRequest.new,
    loansv1loans.LoanRequestRejectResponse.new,
  );

  /// LoanRequestCancel cancels a loan request.
  static const loanRequestCancel = connect.Spec(
    '/$name/LoanRequestCancel',
    connect.StreamType.unary,
    loansv1loans.LoanRequestCancelRequest.new,
    loansv1loans.LoanRequestCancelResponse.new,
  );

  /// ClientProductAccessSave creates or updates a client product access record.
  static const clientProductAccessSave = connect.Spec(
    '/$name/ClientProductAccessSave',
    connect.StreamType.unary,
    loansv1loans.ClientProductAccessSaveRequest.new,
    loansv1loans.ClientProductAccessSaveResponse.new,
  );

  /// ClientProductAccessGet retrieves a client product access record.
  static const clientProductAccessGet = connect.Spec(
    '/$name/ClientProductAccessGet',
    connect.StreamType.unary,
    loansv1loans.ClientProductAccessGetRequest.new,
    loansv1loans.ClientProductAccessGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ClientProductAccessSearch finds client product access records.
  static const clientProductAccessSearch = connect.Spec(
    '/$name/ClientProductAccessSearch',
    connect.StreamType.server,
    loansv1loans.ClientProductAccessSearchRequest.new,
    loansv1loans.ClientProductAccessSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanAccountCreate creates a new loan account from an approved loan request.
  static const loanAccountCreate = connect.Spec(
    '/$name/LoanAccountCreate',
    connect.StreamType.unary,
    loansv1loans.LoanAccountCreateRequest.new,
    loansv1loans.LoanAccountCreateResponse.new,
  );

  /// LoanAccountGet retrieves a loan account by its ID.
  static const loanAccountGet = connect.Spec(
    '/$name/LoanAccountGet',
    connect.StreamType.unary,
    loansv1loans.LoanAccountGetRequest.new,
    loansv1loans.LoanAccountGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanAccountSearch finds loan accounts matching search criteria.
  static const loanAccountSearch = connect.Spec(
    '/$name/LoanAccountSearch',
    connect.StreamType.server,
    loansv1loans.LoanAccountSearchRequest.new,
    loansv1loans.LoanAccountSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanBalanceGet retrieves the current balance of a loan.
  static const loanBalanceGet = connect.Spec(
    '/$name/LoanBalanceGet',
    connect.StreamType.unary,
    loansv1loans.LoanBalanceGetRequest.new,
    loansv1loans.LoanBalanceGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanStatement generates a loan statement for a date range.
  static const loanStatement = connect.Spec(
    '/$name/LoanStatement',
    connect.StreamType.unary,
    loansv1loans.LoanStatementRequest.new,
    loansv1loans.LoanStatementResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// DisbursementCreate initiates a loan disbursement.
  static const disbursementCreate = connect.Spec(
    '/$name/DisbursementCreate',
    connect.StreamType.unary,
    loansv1loans.DisbursementCreateRequest.new,
    loansv1loans.DisbursementCreateResponse.new,
  );

  /// DisbursementGet retrieves a disbursement by its ID.
  static const disbursementGet = connect.Spec(
    '/$name/DisbursementGet',
    connect.StreamType.unary,
    loansv1loans.DisbursementGetRequest.new,
    loansv1loans.DisbursementGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// DisbursementSearch finds disbursements for a loan.
  static const disbursementSearch = connect.Spec(
    '/$name/DisbursementSearch',
    connect.StreamType.server,
    loansv1loans.DisbursementSearchRequest.new,
    loansv1loans.DisbursementSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// RepaymentRecord applies a payment the borrower made from their own
  /// contact to their loan. Only the payment rail calls it, once it has
  /// matched the inbound payment; no person records a repayment.
  static const repaymentRecord = connect.Spec(
    '/$name/RepaymentRecord',
    connect.StreamType.unary,
    loansv1loans.RepaymentRecordRequest.new,
    loansv1loans.RepaymentRecordResponse.new,
  );

  /// RepaymentGet retrieves a repayment by its ID.
  static const repaymentGet = connect.Spec(
    '/$name/RepaymentGet',
    connect.StreamType.unary,
    loansv1loans.RepaymentGetRequest.new,
    loansv1loans.RepaymentGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// RepaymentSearch finds repayments for a loan.
  static const repaymentSearch = connect.Spec(
    '/$name/RepaymentSearch',
    connect.StreamType.server,
    loansv1loans.RepaymentSearchRequest.new,
    loansv1loans.RepaymentSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// RepaymentScheduleGet retrieves the active repayment schedule for a loan.
  static const repaymentScheduleGet = connect.Spec(
    '/$name/RepaymentScheduleGet',
    connect.StreamType.unary,
    loansv1loans.RepaymentScheduleGetRequest.new,
    loansv1loans.RepaymentScheduleGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// PenaltySave creates or updates a penalty on a loan.
  static const penaltySave = connect.Spec(
    '/$name/PenaltySave',
    connect.StreamType.unary,
    loansv1loans.PenaltySaveRequest.new,
    loansv1loans.PenaltySaveResponse.new,
  );

  /// PenaltyWaive waives a penalty on a loan.
  static const penaltyWaive = connect.Spec(
    '/$name/PenaltyWaive',
    connect.StreamType.unary,
    loansv1loans.PenaltyWaiveRequest.new,
    loansv1loans.PenaltyWaiveResponse.new,
  );

  /// PenaltySearch finds penalties for a loan.
  static const penaltySearch = connect.Spec(
    '/$name/PenaltySearch',
    connect.StreamType.server,
    loansv1loans.PenaltySearchRequest.new,
    loansv1loans.PenaltySearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// LoanRestructureCreate requests a loan restructure.
  static const loanRestructureCreate = connect.Spec(
    '/$name/LoanRestructureCreate',
    connect.StreamType.unary,
    loansv1loans.LoanRestructureCreateRequest.new,
    loansv1loans.LoanRestructureCreateResponse.new,
  );

  /// LoanRestructureApprove approves a loan restructure.
  static const loanRestructureApprove = connect.Spec(
    '/$name/LoanRestructureApprove',
    connect.StreamType.unary,
    loansv1loans.LoanRestructureApproveRequest.new,
    loansv1loans.LoanRestructureApproveResponse.new,
  );

  /// LoanRestructureReject rejects a loan restructure.
  static const loanRestructureReject = connect.Spec(
    '/$name/LoanRestructureReject',
    connect.StreamType.unary,
    loansv1loans.LoanRestructureRejectRequest.new,
    loansv1loans.LoanRestructureRejectResponse.new,
  );

  /// LoanRestructureSearch finds restructures for a loan.
  static const loanRestructureSearch = connect.Spec(
    '/$name/LoanRestructureSearch',
    connect.StreamType.server,
    loansv1loans.LoanRestructureSearchRequest.new,
    loansv1loans.LoanRestructureSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ReconciliationSave creates or updates a reconciliation record.
  static const reconciliationSave = connect.Spec(
    '/$name/ReconciliationSave',
    connect.StreamType.unary,
    loansv1loans.ReconciliationSaveRequest.new,
    loansv1loans.ReconciliationSaveResponse.new,
  );

  /// ReconciliationSearch finds reconciliation records.
  static const reconciliationSearch = connect.Spec(
    '/$name/ReconciliationSearch',
    connect.StreamType.server,
    loansv1loans.ReconciliationSearchRequest.new,
    loansv1loans.ReconciliationSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InitiateCollection sends a payment collection prompt to the client.
  static const initiateCollection = connect.Spec(
    '/$name/InitiateCollection',
    connect.StreamType.unary,
    loansv1loans.InitiateCollectionRequest.new,
    loansv1loans.InitiateCollectionResponse.new,
  );

  /// LoanJobRun runs one batch of a periodic job. Called by the platform
  /// scheduler (trustage); only service accounts hold the permission.
  static const loanJobRun = connect.Spec(
    '/$name/LoanJobRun',
    connect.StreamType.unary,
    loansv1loans.LoanJobRunRequest.new,
    loansv1loans.LoanJobRunResponse.new,
  );

  /// LoanStatusChangeSearch retrieves status change audit trail for a loan.
  static const loanStatusChangeSearch = connect.Spec(
    '/$name/LoanStatusChangeSearch',
    connect.StreamType.server,
    loansv1loans.LoanStatusChangeSearchRequest.new,
    loansv1loans.LoanStatusChangeSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// PortfolioSummary returns aggregated financial metrics across a filtered
  /// set of loans. Supports filtering by organization, branch, agent, product, and client.
  static const portfolioSummary = connect.Spec(
    '/$name/PortfolioSummary',
    connect.StreamType.unary,
    loansv1loans.PortfolioSummaryRequest.new,
    loansv1loans.PortfolioSummaryResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// PortfolioExport exports the loan book as CSV for a filtered set of loans.
  static const portfolioExport = connect.Spec(
    '/$name/PortfolioExport',
    connect.StreamType.unary,
    loansv1loans.PortfolioExportRequest.new,
    loansv1loans.PortfolioExportResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );
}
