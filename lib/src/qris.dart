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
  }) : assert(bytes.length > 0),
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
