// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'a7a74252619709cc262a4c9e94f50efa065f8733';

@ProviderFor(currentProfileId)
final currentProfileIdProvider = CurrentProfileIdProvider._();

final class CurrentProfileIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentProfileIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentProfileId(ref);
  }
}

String _$currentProfileIdHash() => r'75ca6c4acd26917b2f3e9b7801fdd0674cccf512';

@ProviderFor(userRoles)
final userRolesProvider = UserRolesProvider._();

final class UserRolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  UserRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRolesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return userRoles(ref);
  }
}

String _$userRolesHash() => r'7ee79817961969fa75243e6659630887677c895f';

@ProviderFor(currentTenantId)
final currentTenantIdProvider = CurrentTenantIdProvider._();

final class CurrentTenantIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentTenantIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTenantIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTenantIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentTenantId(ref);
  }
}

String _$currentTenantIdHash() => r'569cad1dc510d4638e5cf0d318a6a5b1e262a8ae';

@ProviderFor(currentPartitionId)
final currentPartitionIdProvider = CurrentPartitionIdProvider._();

final class CurrentPartitionIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentPartitionIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPartitionIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPartitionIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentPartitionId(ref);
  }
}

String _$currentPartitionIdHash() =>
    r'3026b3bd40031e807464ede174cd866ca7f14a48';

@ProviderFor(currentDisplayName)
final currentDisplayNameProvider = CurrentDisplayNameProvider._();

final class CurrentDisplayNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentDisplayNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDisplayNameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDisplayNameHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentDisplayName(ref);
  }
}

String _$currentDisplayNameHash() =>
    r'd5c17b11173d6dac3cfa64502c55ed28b6cd342a';
