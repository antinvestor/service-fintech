/// Transfer order types.
///
/// This table mirrors `pkg/constants/transfer_types.go`, which is the single
/// source of truth for the wire values. `test/transfer_types_test.dart`
/// enumerates the same values, so a drift between the two shows up as a test
/// failure rather than as an operator staring at a mislabelled row.
library;

import 'package:antinvestor_api_operations/antinvestor_api_operations.dart';

/// A single transfer order type: its wire value, its canonical name as the
/// backend spells it, and the label operators see.
class TransferType {
  const TransferType(this.value, this.name, this.label);

  /// Wire value stored on `TransferOrderObject.orderType`.
  final int value;

  /// Canonical backend name, e.g. `LOAN_REPAYMENT`.
  final String name;

  /// Human-readable label for the UI.
  final String label;
}

/// Every transfer type the backend defines, ordered by wire value.
const List<TransferType> transferTypes = [
  TransferType(1, 'PAYMENT', 'Payment'),
  TransferType(2, 'PAYMENT_IDENTIFIED', 'Payment Identified'),
  TransferType(3, 'PAYMENT_ALLOCATED', 'Payment Allocated'),
  TransferType(6, 'DISBURSEMENT', 'Disbursement'),
  TransferType(7, 'DISBURSEMENT_REVERSAL', 'Disbursement Reversal'),
  TransferType(
    8,
    'DISBURSEMENT_REVERSAL_REROUTE',
    'Disbursement Reversal Reroute',
  ),
  TransferType(9, 'TERMINAL_DISBURSEMENT', 'Terminal Disbursement'),
  TransferType(
    10,
    'TERMINAL_DISBURSEMENT_RECOVERY',
    'Terminal Disbursement Recovery',
  ),
  TransferType(11, 'COST', 'Cost'),
  TransferType(16, 'SERVICE_FEE', 'Service Fee'),
  TransferType(21, 'REGISTRATION_FEE', 'Registration Fee'),
  TransferType(25, 'PERIODIC_SAVING', 'Periodic Saving'),
  TransferType(
    26,
    'PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION',
    'Periodic Savings Interest Income Distribution',
  ),
  TransferType(27, 'PERIODIC_SAVING_RECOVERY', 'Periodic Saving Recovery'),
  TransferType(31, 'PENALTY', 'Penalty'),
  TransferType(32, 'PENALTY_CANCEL', 'Penalty Cancel'),
  TransferType(
    33,
    'PENALTY_INCOME_DISTRIBUTION',
    'Penalty Income Distribution',
  ),
  TransferType(34, 'PENALTY_REPAYMENT', 'Penalty Repayment'),
  TransferType(
    36,
    'LOAN_FUNDING_EXTERNAL_LENDING',
    'Loan Funding External Lending',
  ),
  TransferType(
    37,
    'LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK',
    'Loan Funding External Lending Payback',
  ),
  TransferType(38, 'INVESTOR_DEPLOYMENT', 'Investor Deployment'),
  TransferType(39, 'INVESTOR_PRINCIPAL_RETURN', 'Investor Principal Return'),
  TransferType(
    40,
    'INVESTOR_INCOME_DISTRIBUTION',
    'Investor Income Distribution',
  ),
  TransferType(41, 'LOAN', 'Loan'),
  TransferType(42, 'LOAN_REPAYMENT', 'Loan Repayment'),
  TransferType(43, 'SHUTDOWN_LOAN_RECOVERY', 'Shutdown Loan Recovery'),
  TransferType(
    44,
    'PLATFORM_FIRST_LOSS_ABSORPTION',
    'Platform First Loss Absorption',
  ),
  TransferType(45, 'INVESTOR_LOSS_ABSORPTION', 'Investor Loss Absorption'),
  TransferType(46, 'LOAN_INTEREST', 'Loan Interest'),
  TransferType(47, 'LOAN_INTEREST_REPAYMENT', 'Loan Interest Repayment'),
  TransferType(
    48,
    'LOAN_INTEREST_INCOME_DISTRIBUTION',
    'Loan Interest Income Distribution',
  ),
  TransferType(51, 'LOAN_INSURANCE', 'Loan Insurance'),
  TransferType(52, 'LOAN_INSURANCE_REPAYMENT', 'Loan Insurance Repayment'),
  TransferType(71, 'INTER_SUBSCRIPTION_PAYMENT', 'Inter Subscription Payment'),
];

final Map<int, TransferType> _byValue = {
  for (final type in transferTypes) type.value: type,
};

/// Label for a wire value, falling back to the raw value when the backend
/// introduces a type this build does not know about.
String transferTypeLabel(int value) => _byValue[value]?.label ?? 'Type $value';

/// Resolves a transfer order's type, preferring the enum field and falling
/// back to the deprecated integer that older servers still populate.
int orderTypeValue(TransferOrderObject order) {
  if (order.hasTransferType() &&
      order.transferType != TransferOrderType.TRANSFER_ORDER_TYPE_UNSPECIFIED) {
    return order.transferType.value;
  }
  // ignore: deprecated_member_use
  return order.orderType;
}
