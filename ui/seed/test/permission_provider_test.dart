import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/core/auth/permission_checker.dart';
import 'package:seed_ui/core/auth/permission_provider.dart';

/// Hands the test the container's own [Ref], which is what the router passes to
/// [resolvePermissions].
final refProbeProvider = Provider<Ref>((ref) => ref);

void main() {
  group('PermissionRetryGate', () {
    test('allows the first retry and then throttles', () {
      final gate = PermissionRetryGate();
      final start = DateTime(2026, 1, 1, 12);

      expect(gate.shouldRetry(start), isTrue);
      expect(
        gate.shouldRetry(start.add(const Duration(seconds: 1))),
        isFalse,
        reason: 'a failing backend must not be retried on every navigation',
      );
      expect(
        gate.shouldRetry(start.add(permissionRetryCooldown)),
        isTrue,
        reason: 'the cooldown must expire so the session can recover',
      );
    });
  });

  group('resolvePermissions', () {
    test('does not cache an unavailable resolution', () async {
      var resolutions = 0;
      final container = ProviderContainer(
        overrides: [
          permissionResolutionProvider.overrideWith((ref) async {
            resolutions++;
            return resolutions == 1
                ? const PermissionResolution.unavailable()
                : const PermissionResolution.resolved({'org_view'});
          }),
        ],
      );
      addTearDown(container.dispose);

      final first = await resolvePermissions(container.read(refProbeProvider));
      expect(first.available, isFalse, reason: 'the gate stays fail-closed');

      final second = await resolvePermissions(container.read(refProbeProvider));
      expect(
        second.available,
        isTrue,
        reason: 'the failure must not stick for the whole session',
      );
      expect(second.has('org_view'), isTrue);
      expect(resolutions, 2);
    });

    test('keeps a successful resolution cached', () async {
      var resolutions = 0;
      final container = ProviderContainer(
        overrides: [
          permissionResolutionProvider.overrideWith((ref) async {
            resolutions++;
            return const PermissionResolution.resolved({'org_view'});
          }),
        ],
      );
      addTearDown(container.dispose);

      await resolvePermissions(container.read(refProbeProvider));
      await resolvePermissions(container.read(refProbeProvider));

      expect(
        resolutions,
        1,
        reason: 'only failures are discarded, not every resolution',
      );
    });
  });
}
