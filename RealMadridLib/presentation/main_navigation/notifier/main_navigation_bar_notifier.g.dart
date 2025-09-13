// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_navigation_bar_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mainNavigationBarNotifierHash() =>
    r'09fec24e1be3b5bc878c894846857c791c2b281b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MainNavigationBarNotifier
    extends BuildlessAutoDisposeNotifier<MainNavigationState> {
  late final StatefulNavigationShell navigationShell;

  MainNavigationState build(StatefulNavigationShell navigationShell);
}

/// See also [MainNavigationBarNotifier].
@ProviderFor(MainNavigationBarNotifier)
const mainNavigationBarNotifierProvider = MainNavigationBarNotifierFamily();

/// See also [MainNavigationBarNotifier].
class MainNavigationBarNotifierFamily extends Family<MainNavigationState> {
  /// See also [MainNavigationBarNotifier].
  const MainNavigationBarNotifierFamily();

  /// See also [MainNavigationBarNotifier].
  MainNavigationBarNotifierProvider call(
    StatefulNavigationShell navigationShell,
  ) {
    return MainNavigationBarNotifierProvider(navigationShell);
  }

  @override
  MainNavigationBarNotifierProvider getProviderOverride(
    covariant MainNavigationBarNotifierProvider provider,
  ) {
    return call(provider.navigationShell);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mainNavigationBarNotifierProvider';
}

/// See also [MainNavigationBarNotifier].
class MainNavigationBarNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          MainNavigationBarNotifier,
          MainNavigationState
        > {
  /// See also [MainNavigationBarNotifier].
  MainNavigationBarNotifierProvider(StatefulNavigationShell navigationShell)
    : this._internal(
        () => MainNavigationBarNotifier()..navigationShell = navigationShell,
        from: mainNavigationBarNotifierProvider,
        name: r'mainNavigationBarNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mainNavigationBarNotifierHash,
        dependencies: MainNavigationBarNotifierFamily._dependencies,
        allTransitiveDependencies:
            MainNavigationBarNotifierFamily._allTransitiveDependencies,
        navigationShell: navigationShell,
      );

  MainNavigationBarNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.navigationShell,
  }) : super.internal();

  final StatefulNavigationShell navigationShell;

  @override
  MainNavigationState runNotifierBuild(
    covariant MainNavigationBarNotifier notifier,
  ) {
    return notifier.build(navigationShell);
  }

  @override
  Override overrideWith(MainNavigationBarNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MainNavigationBarNotifierProvider._internal(
        () => create()..navigationShell = navigationShell,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        navigationShell: navigationShell,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    MainNavigationBarNotifier,
    MainNavigationState
  >
  createElement() {
    return _MainNavigationBarNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MainNavigationBarNotifierProvider &&
        other.navigationShell == navigationShell;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, navigationShell.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MainNavigationBarNotifierRef
    on AutoDisposeNotifierProviderRef<MainNavigationState> {
  /// The parameter `navigationShell` of this provider.
  StatefulNavigationShell get navigationShell;
}

class _MainNavigationBarNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          MainNavigationBarNotifier,
          MainNavigationState
        >
    with MainNavigationBarNotifierRef {
  _MainNavigationBarNotifierProviderElement(super.provider);

  @override
  StatefulNavigationShell get navigationShell =>
      (origin as MainNavigationBarNotifierProvider).navigationShell;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
