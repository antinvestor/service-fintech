import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The wire values and canonical names defined by
/// `pkg/constants/transfer_types.go`. Listing them here independently of the
/// library table means a drift on either side fails this test instead of
/// silently mislabelling rows in the operator UI.
const Map<int, String> backendTransferTypes = {
  1: 'PAYMENT',
  2: 'PAYMENT_IDENTIFIED',
  3: 'PAYMENT_ALLOCATED',
  6: 'DISBURSEMENT',
  7: 'DISBURSEMENT_REVERSAL',
  8: 'DISBURSEMENT_REVERSAL_REROUTE',
  9: 'TERMINAL_DISBURSEMENT',
  10: 'TERMINAL_DISBURSEMENT_RECOVERY',
  11: 'COST',
  16: 'SERVICE_FEE',
  21: 'REGISTRATION_FEE',
  25: 'PERIODIC_SAVING',
  26: 'PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION',
  27: 'PERIODIC_SAVING_RECOVERY',
  31: 'PENALTY',
  32: 'PENALTY_CANCEL',
  33: 'PENALTY_INCOME_DISTRIBUTION',
  36: 'LOAN_FUNDING_EXTERNAL_LENDING',
  37: 'LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK',
  38: 'INVESTOR_DEPLOYMENT',
  39: 'INVESTOR_PRINCIPAL_RETURN',
  40: 'INVESTOR_INCOME_DISTRIBUTION',
  41: 'LOAN',
  42: 'LOAN_REPAYMENT',
  43: 'SHUTDOWN_LOAN_RECOVERY',
  44: 'PLATFORM_FIRST_LOSS_ABSORPTION',
  45: 'INVESTOR_LOSS_ABSORPTION',
  46: 'LOAN_INTEREST',
  47: 'LOAN_INTEREST_REPAYMENT',
  48: 'LOAN_INTEREST_INCOME_DISTRIBUTION',
  51: 'LOAN_INSURANCE',
  52: 'LOAN_INSURANCE_REPAYMENT',
  71: 'INTER_SUBSCRIPTION_PAYMENT',
};

void main() {
  group('transferTypes', () {
    test('covers exactly the backend transfer type values', () {
      final values = transferTypes.map((t) => t.value).toList();
      expect(values, backendTransferTypes.keys.toList());
    });

    test('uses the backend canonical names', () {
      for (final type in transferTypes) {
        expect(
          type.name,
          backendTransferTypes[type.value],
          reason: 'value ${type.value}',
        );
      }
    });

    test('is ordered by wire value and has no duplicates', () {
      final values = transferTypes.map((t) => t.value).toList();
      final sorted = [...values]..sort();
      expect(values, sorted);
      expect(values.toSet().length, values.length);
    });

    test('every entry has a non-empty label', () {
      for (final type in transferTypes) {
        expect(type.label, isNotEmpty, reason: 'value ${type.value}');
      }
    });
  });

  group('transferTypeLabel', () {
    test('labels the values the audit flagged as mislabelled', () {
      expect(transferTypeLabel(1), 'Payment');
      expect(transferTypeLabel(6), 'Disbursement');
      expect(transferTypeLabel(31), 'Penalty');
      expect(transferTypeLabel(42), 'Loan Repayment');
      expect(transferTypeLabel(46), 'Loan Interest');
    });

    test('falls back to the raw value for unknown types', () {
      expect(transferTypeLabel(4), 'Type 4');
      expect(transferTypeLabel(9999), 'Type 9999');
    });
  });
}
