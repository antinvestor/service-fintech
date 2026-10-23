import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('orgTypeLabel', () {
    test('gives every proto value a human readable label', () {
      for (final type in OrganizationType.values) {
        final label = orgTypeLabel(type);
        expect(label, isNotEmpty, reason: '${type.name} has no label');
        expect(
          label,
          isNot(equals(type.name)),
          reason: '${type.name} falls through to the raw enum name',
        );
      }
    });

    test('offers every proto value in the picker', () {
      expect(
        organizationTypeOptions.toSet(),
        equals(OrganizationType.values.toSet()),
        reason: 'the organization type dropdown must be exhaustive',
      );
      expect(
        organizationTypeOptions.length,
        equals(organizationTypeOptions.toSet().length),
        reason: 'the picker must not repeat a type',
      );
    });
  });

  group('orgUnitTypeLabel', () {
    test('gives every proto value a human readable label', () {
      for (final type in OrgUnitType.values) {
        expect(orgUnitTypeLabel(type), isNotEmpty);
        expect(orgUnitTypeLabel(type), isNot(equals(type.name)));
      }
    });

    test('offers every type except the unspecified one for editing', () {
      expect(
        editableOrgUnitTypes.toSet(),
        equals(
          OrgUnitType.values
              .where((t) => t != OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED)
              .toSet(),
        ),
      );
    });
  });

  group('scopeLabel', () {
    test('gives every access scope a human readable label', () {
      for (final scope in AccessScopeType.values) {
        expect(scopeLabel(scope), isNotEmpty);
        expect(scopeLabel(scope), isNot(equals(scope.name)));
      }
    });
  });

  group('engagementLabel', () {
    test('titlecases organization defined values', () {
      expect(engagementLabel('service_account'), 'Service Account');
      expect(engagementLabel('employee'), 'Employee');
    });

    test('names the empty value rather than rendering blank', () {
      expect(engagementLabel(''), 'Unspecified');
      expect(teamTypeLabel(''), 'Unspecified');
      expect(membershipRoleLabel(''), 'Unspecified');
    });
  });
}
