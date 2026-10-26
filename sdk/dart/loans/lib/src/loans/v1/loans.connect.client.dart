//
//  Generated code. Do not modify.
//  source: loans/v1/loans.proto
//

import "package:connectrpc/connect.dart" as connect;
import "loans.pb.dart" as loansv1loans;
import "loans.connect.spec.dart" as specs;

/// LoanManagementService manages active loans, disbursements, repayments,
/// schedules, penalties, restructures, and reconciliation.
/// All RPCs require authentication via Bearer token.
extension type LoanManagementServiceClient (connect.Transport _transport) {
  /// LoanProductSave creates or updates a loan product.
  Future<loansv1loans.LoanProductSaveResponse> loanProductSave(
    loansv1loans.LoanProductSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanProductSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanProductGet retrieves a loan product by its ID.
  Future<loansv1loans.LoanProductGetResponse> loanProductGet(
    loansv1loans.LoanProductGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanProductGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanProductSearch finds loan products matching search criteria.
  Stream<loansv1loans.LoanProductSearchResponse> loanProductSearch(
    loansv1loans.LoanProductSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.loanProductSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRequestSave creates or updates a loan request. Called by product services
  /// (seed, stawi, etc.) after completing their own acquisition workflows.
  Future<loansv1loans.LoanRequestSaveResponse> loanRequestSave(
    loansv1loans.LoanRequestSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRequestSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRequestGet retrieves a loan request by its ID.
  Future<loansv1loans.LoanRequestGetResponse> loanRequestGet(
    loansv1loans.LoanRequestGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRequestGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRequestSearch finds loan requests matching search criteria.
  Stream<loansv1loans.LoanRequestSearchResponse> loanRequestSearch(
    loansv1loans.LoanRequestSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.loanRequestSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRequestApprove approves a loan request and creates the loan account.
  Future<loansv1loans.LoanRequestApproveResponse> loanRequestApprove(
    loansv1loans.LoanRequestApproveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRequestApprove,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRequestReject rejects a loan request with a reason.
  Future<loansv1loans.LoanRequestRejectResponse> loanRequestReject(
    loansv1loans.LoanRequestRejectRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRequestReject,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRequestCancel cancels a loan request.
  Future<loansv1loans.LoanRequestCancelResponse> loanRequestCancel(
    loansv1loans.LoanRequestCancelRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRequestCancel,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ClientProductAccessSave creates or updates a client product access record.
  Future<loansv1loans.ClientProductAccessSaveResponse> clientProductAccessSave(
    loansv1loans.ClientProductAccessSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.clientProductAccessSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ClientProductAccessGet retrieves a client product access record.
  Future<loansv1loans.ClientProductAccessGetResponse> clientProductAccessGet(
    loansv1loans.ClientProductAccessGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.clientProductAccessGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ClientProductAccessSearch finds client product access records.
  Stream<loansv1loans.ClientProductAccessSearchResponse> clientProductAccessSearch(
    loansv1loans.ClientProductAccessSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.clientProductAccessSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanAccountCreate creates a new loan account from an approved loan request.
  Future<loansv1loans.LoanAccountCreateResponse> loanAccountCreate(
    loansv1loans.LoanAccountCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanAccountCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanAccountCancel closes a loan that was opened but never disbursed and
  /// gives its funders back the capital reserved for it.
  Future<loansv1loans.LoanAccountCancelResponse> loanAccountCancel(
    loansv1loans.LoanAccountCancelRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanAccountCancel,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanAccountGet retrieves a loan account by its ID.
  Future<loansv1loans.LoanAccountGetResponse> loanAccountGet(
    loansv1loans.LoanAccountGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanAccountGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanAccountSearch finds loan accounts matching search criteria.
  Stream<loansv1loans.LoanAccountSearchResponse> loanAccountSearch(
    loansv1loans.LoanAccountSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.loanAccountSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanBalanceGet retrieves the current balance of a loan.
  Future<loansv1loans.LoanBalanceGetResponse> loanBalanceGet(
    loansv1loans.LoanBalanceGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanBalanceGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanStatement generates a loan statement for a date range.
  Future<loansv1loans.LoanStatementResponse> loanStatement(
    loansv1loans.LoanStatementRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanStatement,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DisbursementCreate initiates a loan disbursement.
  Future<loansv1loans.DisbursementCreateResponse> disbursementCreate(
    loansv1loans.DisbursementCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.disbursementCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DisbursementGet retrieves a disbursement by its ID.
  Future<loansv1loans.DisbursementGetResponse> disbursementGet(
    loansv1loans.DisbursementGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.disbursementGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DisbursementSearch finds disbursements for a loan.
  Stream<loansv1loans.DisbursementSearchResponse> disbursementSearch(
    loansv1loans.DisbursementSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.disbursementSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// RepaymentRecord applies a payment the borrower made from their own
  /// contact to their loan. Only the payment rail calls it, once it has
  /// matched the inbound payment; no person records a repayment.
  Future<loansv1loans.RepaymentRecordResponse> repaymentRecord(
    loansv1loans.RepaymentRecordRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.repaymentRecord,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// RepaymentGet retrieves a repayment by its ID.
  Future<loansv1loans.RepaymentGetResponse> repaymentGet(
    loansv1loans.RepaymentGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.repaymentGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// RepaymentSearch finds repayments for a loan.
  Stream<loansv1loans.RepaymentSearchResponse> repaymentSearch(
    loansv1loans.RepaymentSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.repaymentSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// RepaymentScheduleGet retrieves the active repayment schedule for a loan.
  Future<loansv1loans.RepaymentScheduleGetResponse> repaymentScheduleGet(
    loansv1loans.RepaymentScheduleGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.repaymentScheduleGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PenaltySave creates or updates a penalty on a loan.
  Future<loansv1loans.PenaltySaveResponse> penaltySave(
    loansv1loans.PenaltySaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.penaltySave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PenaltyWaive waives a penalty on a loan.
  Future<loansv1loans.PenaltyWaiveResponse> penaltyWaive(
    loansv1loans.PenaltyWaiveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.penaltyWaive,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PenaltySearch finds penalties for a loan.
  Stream<loansv1loans.PenaltySearchResponse> penaltySearch(
    loansv1loans.PenaltySearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.penaltySearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRestructureCreate requests a loan restructure.
  Future<loansv1loans.LoanRestructureCreateResponse> loanRestructureCreate(
    loansv1loans.LoanRestructureCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRestructureCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRestructureApprove approves a loan restructure.
  Future<loansv1loans.LoanRestructureApproveResponse> loanRestructureApprove(
    loansv1loans.LoanRestructureApproveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRestructureApprove,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRestructureReject rejects a loan restructure.
  Future<loansv1loans.LoanRestructureRejectResponse> loanRestructureReject(
    loansv1loans.LoanRestructureRejectRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanRestructureReject,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRestructureSearch finds restructures for a loan.
  Stream<loansv1loans.LoanRestructureSearchResponse> loanRestructureSearch(
    loansv1loans.LoanRestructureSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.loanRestructureSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ReconciliationSave creates or updates a reconciliation record.
  Future<loansv1loans.ReconciliationSaveResponse> reconciliationSave(
    loansv1loans.ReconciliationSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.reconciliationSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ReconciliationSearch finds reconciliation records.
  Stream<loansv1loans.ReconciliationSearchResponse> reconciliationSearch(
    loansv1loans.ReconciliationSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.reconciliationSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// InitiateCollection sends a payment collection prompt to the client.
  Future<loansv1loans.InitiateCollectionResponse> initiateCollection(
    loansv1loans.InitiateCollectionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.initiateCollection,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// TeamCommissionSearch lists teams' commission balances.
  Stream<loansv1loans.TeamCommissionSearchResponse> teamCommissionSearch(
    loansv1loans.TeamCommissionSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.teamCommissionSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// TeamCommissionPayout pays a team's accrued commission to one of its
  /// members' own verified mobile money.
  Future<loansv1loans.TeamCommissionPayoutResponse> teamCommissionPayout(
    loansv1loans.TeamCommissionPayoutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.teamCommissionPayout,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// TeamCommissionPayoutSearch lists a team's commission payouts.
  Stream<loansv1loans.TeamCommissionPayoutSearchResponse> teamCommissionPayoutSearch(
    loansv1loans.TeamCommissionPayoutSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.teamCommissionPayoutSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanJobRun runs one batch of a periodic job. Called by the platform
  /// scheduler (trustage); only service accounts hold the permission.
  Future<loansv1loans.LoanJobRunResponse> loanJobRun(
    loansv1loans.LoanJobRunRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.loanJobRun,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanStatusChangeSearch retrieves status change audit trail for a loan.
  Stream<loansv1loans.LoanStatusChangeSearchResponse> loanStatusChangeSearch(
    loansv1loans.LoanStatusChangeSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LoanManagementService.loanStatusChangeSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PortfolioSummary returns aggregated financial metrics across a filtered
  /// set of loans. Supports filtering by organization, branch, agent, product, and client.
  Future<loansv1loans.PortfolioSummaryResponse> portfolioSummary(
    loansv1loans.PortfolioSummaryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.portfolioSummary,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PortfolioExport exports the loan book as CSV for a filtered set of loans.
  Future<loansv1loans.PortfolioExportResponse> portfolioExport(
    loansv1loans.PortfolioExportRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LoanManagementService.portfolioExport,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
