// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appReaderHash() => r'277be6e4d7ec6f107d54f1d08668f7d46704cfc1';

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

abstract class _$AppReader extends BuildlessAutoDisposeNotifier<Reader> {
  late final (String, String, int) arg;

  Reader build(
    (String, String, int) arg,
  );
}

/// See also [AppReader].
@ProviderFor(AppReader)
const appReaderProvider = AppReaderFamily();

/// See also [AppReader].
class AppReaderFamily extends Family<Reader> {
  /// See also [AppReader].
  const AppReaderFamily();

  /// See also [AppReader].
  AppReaderProvider call(
    (String, String, int) arg,
  ) {
    return AppReaderProvider(
      arg,
    );
  }

  @override
  AppReaderProvider getProviderOverride(
    covariant AppReaderProvider provider,
  ) {
    return call(
      provider.arg,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'appReaderProvider';
}

/// See also [AppReader].
class AppReaderProvider
    extends AutoDisposeNotifierProviderImpl<AppReader, Reader> {
  /// See also [AppReader].
  AppReaderProvider(
    (String, String, int) arg,
  ) : this._internal(
          () => AppReader()..arg = arg,
          from: appReaderProvider,
          name: r'appReaderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appReaderHash,
          dependencies: AppReaderFamily._dependencies,
          allTransitiveDependencies: AppReaderFamily._allTransitiveDependencies,
          arg: arg,
        );

  AppReaderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.arg,
  }) : super.internal();

  final (String, String, int) arg;

  @override
  Reader runNotifierBuild(
    covariant AppReader notifier,
  ) {
    return notifier.build(
      arg,
    );
  }

  @override
  Override overrideWith(AppReader Function() create) {
    return ProviderOverride(
      origin: this,
      override: AppReaderProvider._internal(
        () => create()..arg = arg,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        arg: arg,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AppReader, Reader> createElement() {
    return _AppReaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppReaderProvider && other.arg == arg;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, arg.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AppReaderRef on AutoDisposeNotifierProviderRef<Reader> {
  /// The parameter `arg` of this provider.
  (String, String, int) get arg;
}

class _AppReaderProviderElement
    extends AutoDisposeNotifierProviderElement<AppReader, Reader>
    with AppReaderRef {
  _AppReaderProviderElement(super.provider);

  @override
  (String, String, int) get arg => (origin as AppReaderProvider).arg;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
