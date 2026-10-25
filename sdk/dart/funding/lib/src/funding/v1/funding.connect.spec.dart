//
//  Generated code. Do not modify.
//  source: funding/v1/funding.proto
//

import "package:connectrpc/connect.dart" as connect;
import "funding.pb.dart" as fundingv1funding;

abstract final class FundingService {
  /// Fully-qualified name of the FundingService service.
  static const name = 'funding.v1.FundingService';

  static const investorAccountSave = connect.Spec(
    '/$name/InvestorAccountSave',
    connect.StreamType.unary,
    fundingv1funding.InvestorAccountSaveRequest.new,
    fundingv1funding.InvestorAccountSaveResponse.new,
  );

  static const investorAccountGet = connect.Spec(
    '/$name/InvestorAccountGet',
    connect.StreamType.unary,
    fundingv1funding.InvestorAccountGetRequest.new,
    fundingv1funding.InvestorAccountGetResponse.new,
  );

  static const investorAccountSearch = connect.Spec(
    '/$name/InvestorAccountSearch',
    connect.StreamType.server,
    fundingv1funding.InvestorAccountSearchRequest.new,
    fundingv1funding.InvestorAccountSearchResponse.new,
  );

  static const investorDeposit = connect.Spec(
    '/$name/InvestorDeposit',
    connect.StreamType.unary,
    fundingv1funding.InvestorDepositRequest.new,
    fundingv1funding.InvestorDepositResponse.new,
  );

  static const investorWithdraw = connect.Spec(
    '/$name/InvestorWithdraw',
    connect.StreamType.unary,
    fundingv1funding.InvestorWithdrawRequest.new,
    fundingv1funding.InvestorWithdrawResponse.new,
  );

  static const fundLoan = connect.Spec(
    '/$name/FundLoan',
    connect.StreamType.unary,
    fundingv1funding.FundLoanRequest.new,
    fundingv1funding.FundLoanResponse.new,
  );

  static const absorbLoss = connect.Spec(
    '/$name/AbsorbLoss',
    connect.StreamType.unary,
    fundingv1funding.AbsorbLossRequest.new,
    fundingv1funding.AbsorbLossResponse.new,
  );

  /// LoanRepaymentApply shares a loan repayment out to the loan's funders:
  /// principal back to their capital, interest net of fee and tax as income.
  static const loanRepaymentApply = connect.Spec(
    '/$name/LoanRepaymentApply',
    connect.StreamType.unary,
    fundingv1funding.LoanRepaymentApplyRequest.new,
    fundingv1funding.LoanRepaymentApplyResponse.new,
  );
}
