import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every permit the loans screens gate on is in the manifest', () {
    final keys = LoansRouteModule().permissionManifest.permissions
        .map((p) => p.key)
        .toSet();
    expect(
      keys,
      containsAll(<String>[
        'loan_view',
        'loan_manage',
        'loan_product_view',
        'loan_product_manage',
        'loan_request_view',
        'loan_request_submit',
        'loan_request_manage',
        'collection_manage',
        'disbursement_manage',
        'penalty_manage',
        'restructure_manage',
        'portfolio_view',
        'portfolio_export',
      ]),
    );
  });

  test('no screen offers to record a repayment by hand', () {
    final module = LoansRouteModule();
    expect(
      module.permissionManifest.permissions.map((p) => p.key),
      isNot(contains('repayment_manage')),
    );
    expect(module.routePermissions.keys, isNot(contains('/loans/collections')));
  });
}
