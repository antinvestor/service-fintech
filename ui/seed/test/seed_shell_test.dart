import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/core/responsive/seed_shell.dart';

void main() {
  test('phone navigation highlights the longest matching destination', () {
    final destinations = phoneDestinations(canCollect: true);
    String? labelFor(String location) {
      final i = phoneDestinationIndex(destinations, location);
      return i == null ? null : destinations[i].label;
    }

    expect(labelFor('/'), 'Home');
    expect(labelFor('/clients/c-1'), 'Clients');
    expect(labelFor('/loans/loan-1'), 'Loans');
    expect(labelFor('/loans/collections'), 'Collections');
    expect(labelFor('/organizations'), isNull);
  });

  test('collections are offered only to callers who record repayments', () {
    expect(
      phoneDestinations(canCollect: false).map((d) => d.label),
      isNot(contains('Collections')),
    );
  });
}
