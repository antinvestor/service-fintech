import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/core/responsive/seed_shell.dart';

void main() {
  test('phone navigation highlights the longest matching destination', () {
    final destinations = phoneDestinations();
    String? labelFor(String location) {
      final i = phoneDestinationIndex(destinations, location);
      return i == null ? null : destinations[i].label;
    }

    expect(labelFor('/'), 'Home');
    expect(labelFor('/clients/c-1'), 'Clients');
    expect(labelFor('/loans/loan-1'), 'Loans');
    expect(labelFor('/loans/collections'), 'Loans');
    expect(labelFor('/organizations'), isNull);
  });

  test('no one is offered a collections screen: borrowers pay themselves', () {
    expect(
      phoneDestinations().map((d) => d.label),
      isNot(contains('Collections')),
    );
  });
}
