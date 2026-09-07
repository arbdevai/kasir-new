import 'dart:typed_data';

/// Portable backup payload returned by a [BackupService].
class BackupArtifact {
  const BackupArtifact({
    required this.bytes,
    required this.fileName,
    required this.contentType,
    this.createdAt,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
  final DateTime? createdAt;
}

/// Options controlling backup serialization without selecting a storage API.
class BackupOptions {
  const BackupOptions({
    this.fileName = 'kasir-backup.kasir',
    this.contentType = 'application/octet-stream',
  });

  final String fileName;
  final String contentType;
}

/// Result of validating a candidate backup before restore.
class RestoreValidation {
  const RestoreValidation.valid({this.message = 'Backup is valid'})
      : isValid = true;
  const RestoreValidation.invalid(this.message) : isValid = false;

  final bool isValid;
  final String message;
}

/// Application-owned contract for exporting and restoring local data.
///
/// Implementations decide how data is serialized, encrypted, and persisted.
/// Callers can therefore use this contract with files, a share sheet, or any
/// other local transport without introducing platform dependencies here.
abstract interface class BackupService {
  Future<BackupArtifact> createBackup({BackupOptions options = const BackupOptions()});

  Future<RestoreValidation> validateBackup(Uint8List bytes);

  Future<void> restoreBackup(Uint8List bytes);
}

/// Minimal byte-oriented persistence boundary for local backup files.
abstract interface class BackupStore {
  Future<void> save(BackupArtifact artifact);

  Future<BackupArtifact?> load(String fileName);

  Future<void> delete(String fileName);
}
