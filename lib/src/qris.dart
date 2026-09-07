import 'dart:typed_data';

/// Lifecycle state for the configured static QRIS image.
enum QrisImageState { empty, ready, replacing, invalid }

/// Describes a QRIS image kept by the application.
///
/// The service intentionally stores bytes and metadata only. It does not
/// assume a file system, image picker, payment provider, or renderer.
class QrisImageConfiguration {
  const QrisImageConfiguration({
    required this.bytes,
    required this.mimeType,
    this.fileName,
    this.altText = 'QRIS payment code',
  })  : assert(bytes.length > 0),
        assert(mimeType != '');

  /// Encoded image bytes (for example PNG or JPEG).
  final List<int> bytes;

  /// MIME type such as `image/png`.
  final String mimeType;

  /// Optional user-facing name for the image.
  final String? fileName;

  /// Accessible description for a preview.
  final String altText;

  QrisImageConfiguration copyWith({
    List<int>? bytes,
    String? mimeType,
    String? fileName,
    String? altText,
  }) {
    return QrisImageConfiguration(
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
      fileName: fileName ?? this.fileName,
      altText: altText ?? this.altText,
    );
  }
}

/// Read-only QRIS image state exposed to UI and checkout integrations.
class QrisImageSnapshot {
  const QrisImageSnapshot({this.configuration, this.state = QrisImageState.empty, this.message});

  final QrisImageConfiguration? configuration;
  final QrisImageState state;
  final String? message;

  bool get isConfigured => configuration != null && state == QrisImageState.ready;
}

/// App-owned hooks for persisting and removing a QRIS image.
///
/// Implement these with the selected local persistence or file picker adapter;
/// no image, storage, or platform plugin is bundled into the service layer.
abstract interface class QrisImageStore {
  Future<QrisImageConfiguration?> load();
  Future<void> save(QrisImageConfiguration configuration);
  Future<void> clear();
}

/// Optional hook used by the UI to render a configured QRIS preview.
typedef QrisPreviewBuilder = Object? Function(QrisImageConfiguration configuration);

/// QRIS state/configuration controller with storage and rendering hooks.
///
/// The controller never interprets image bytes and never handles payment
/// amounts. Checkout screens can use [snapshot] to decide whether to show the
/// static image alongside the total.
class QrisImageController {
  QrisImageController({this.store, this.onChanged, this.previewBuilder});

  final QrisImageStore? store;
  final void Function(QrisImageSnapshot snapshot)? onChanged;
  final QrisPreviewBuilder? previewBuilder;

  QrisImageSnapshot _snapshot = const QrisImageSnapshot();
  QrisImageSnapshot get snapshot => _snapshot;

  /// Load previously persisted configuration. Missing images are normal.
  Future<QrisImageSnapshot> load() async {
    if (store == null) return _publish(_snapshot);
    try {
      final configuration = await store!.load();
      return _publish(QrisImageSnapshot(
        configuration: configuration,
        state: configuration == null ? QrisImageState.empty : QrisImageState.ready,
      ));
    } catch (error) {
      return _publish(QrisImageSnapshot(state: QrisImageState.invalid, message: 'QRIS tidak dapat dimuat: $error'));
    }
  }

  /// Validates and persists a replacement image.
  Future<QrisImageSnapshot> setImage(QrisImageConfiguration configuration) async {
    final mime = configuration.mimeType.toLowerCase();
    if (!mime.startsWith('image/')) {
      return _publish(const QrisImageSnapshot(
        state: QrisImageState.invalid,
        message: 'File QRIS harus berupa gambar',
      ));
    }
    if (configuration.bytes.isEmpty) {
      return _publish(const QrisImageSnapshot(
        state: QrisImageState.invalid,
        message: 'File QRIS kosong',
      ));
    }

    _publish(QrisImageSnapshot(
      configuration: _snapshot.configuration,
      state: QrisImageState.replacing,
    ));
    try {
      await store?.save(configuration);
      return _publish(QrisImageSnapshot(
        configuration: configuration,
        state: QrisImageState.ready,
      ));
    } catch (error) {
      return _publish(QrisImageSnapshot(
        configuration: _snapshot.configuration,
        state: QrisImageState.invalid,
        message: 'QRIS tidak dapat disimpan: $error',
      ));
    }
  }

  Future<QrisImageSnapshot> clear() async {
    try {
      await store?.clear();
      return _publish(const QrisImageSnapshot());
    } catch (error) {
      return _publish(QrisImageSnapshot(
        configuration: _snapshot.configuration,
        state: QrisImageState.invalid,
        message: 'QRIS tidak dapat dihapus: $error',
      ));
    }
  }

  /// Produces a renderer-specific preview object through the injected hook.
  Object? buildPreview() {
    final configuration = _snapshot.configuration;
    if (configuration == null || !_snapshot.isConfigured) return null;
    return previewBuilder?.call(configuration);
  }

  QrisImageSnapshot _publish(QrisImageSnapshot next) {
    _snapshot = next;
    onChanged?.call(next);
    return next;
  }
}

/// In-memory implementation useful for tests and app previews.
class MemoryQrisImageStore implements QrisImageStore {
  QrisImageConfiguration? _configuration;

  @override
  Future<QrisImageConfiguration?> load() async => _configuration;

  @override
  Future<void> save(QrisImageConfiguration configuration) async {
    _configuration = configuration;
  }

  @override
  Future<void> clear() async {
    _configuration = null;
  }
}

/// Helper for passing image bytes to Flutter's [Image.memory] without making
/// Flutter a dependency of this package.
Uint8List qrisBytes(QrisImageConfiguration configuration) =>
    Uint8List.fromList(configuration.bytes);
