//
//  Generated code. Do not modify.
//  source: funding/v1/funding.proto
//

import "package:connectrpc/connect.dart" as connect;
import "funding.pb.dart" as fundingv1funding;
import "funding.connect.spec.dart" as specs;

extension type FundingServiceClient (connect.Transport _transport) {
  Future<fundingv1funding.InvestorAccountSaveResponse> investorAccountSave(
    fundingv1funding.InvestorAccountSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.investorAccountSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<fundingv1funding.InvestorAccountGetResponse> investorAccountGet(
    fundingv1funding.InvestorAccountGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.investorAccountGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<fundingv1funding.InvestorAccountSearchResponse> investorAccountSearch(
    fundingv1funding.InvestorAccountSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.FundingService.investorAccountSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<fundingv1funding.InvestorDepositResponse> investorDeposit(
    fundingv1funding.InvestorDepositRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.investorDeposit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<fundingv1funding.InvestorWithdrawResponse> investorWithdraw(
    fundingv1funding.InvestorWithdrawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.investorWithdraw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<fundingv1funding.FundLoanResponse> fundLoan(
    fundingv1funding.FundLoanRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.fundLoan,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<fundingv1funding.AbsorbLossResponse> absorbLoss(
    fundingv1funding.AbsorbLossRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.absorbLoss,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// FundingRelease returns the capital reserved for a loan request whose
  /// loan was cancelled before disbursement. Repeating it releases nothing
  /// more.
  Future<fundingv1funding.FundingReleaseResponse> fundingRelease(
    fundingv1funding.FundingReleaseRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.fundingRelease,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRepaymentApply shares a loan repayment out to the loan's funders:
  /// principal back to their capital, interest net of fee and tax as income.
  Future<fundingv1funding.LoanRepaymentApplyResponse> loanRepaymentApply(
    fundingv1funding.LoanRepaymentApplyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.loanRepaymentApply,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LoanRecoveryApply returns principal recovered from a written-off loan to
  /// the funders who absorbed its loss, most senior tranche first.
  Future<fundingv1funding.LoanRecoveryApplyResponse> loanRecoveryApply(
    fundingv1funding.LoanRecoveryApplyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FundingService.loanRecoveryApply,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
