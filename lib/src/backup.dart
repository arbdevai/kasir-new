import 'dart:convert';
import 'dart:typed_data';

import '../state/pos_state.dart';
import '../state/pos_state_serialization.dart';

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
    this.contentType = 'application/json',
  });

  final String fileName;
  final String contentType;
}

/// Result of validating a candidate backup before restore.
class RestoreValidation {
  const RestoreValidation.valid({this.message = 'Backup is valid'}) : isValid = true;
  const RestoreValidation.invalid(this.message) : isValid = false;

  final bool isValid;
  final String message;
}

/// Application-owned contract for exporting and restoring local data.
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

/// Versioned, checksummed JSON backup implementation for the active [PosState].
///
/// The state is converted to plain JSON values before encoding. Restores are
/// validated and decoded completely before the live state is replaced.
class VersionedJsonBackupService implements BackupService {
  VersionedJsonBackupService(this.state);

  static const String magic = 'KASIR_BACKUP';
  static const int version = 1;

  final PosState state;

  @override
  Future<BackupArtifact> createBackup({BackupOptions options = const BackupOptions()}) async {
    final createdAt = DateTime.now().toUtc();
    final payload = state.toBackupMap();
    final payloadJson = jsonEncode(payload);
    final checksum = _Sha256.hex(utf8.encode(payloadJson));
    final envelope = <String, dynamic>{
      'magic': magic,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'checksum': checksum,
      'payload': payload,
    };
    return BackupArtifact(
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(envelope))),
      fileName: options.fileName,
      contentType: options.contentType,
      createdAt: createdAt,
    );
  }

  @override
  Future<RestoreValidation> validateBackup(Uint8List bytes) async {
    try {
      final envelope = _decodeEnvelope(bytes);
      final payloadJson = jsonEncode(envelope['payload']);
      final expected = _Sha256.hex(utf8.encode(payloadJson));
      if (envelope['checksum'] != expected) {
        return const RestoreValidation.invalid('Checksum tidak cocok');
      }
      return const RestoreValidation.valid();
    } on FormatException catch (error) {
      return RestoreValidation.invalid(error.message);
    } catch (_) {
      return const RestoreValidation.invalid('Format backup tidak valid');
    }
  }

  @override
  Future<void> restoreBackup(Uint8List bytes) async {
    final validation = await validateBackup(bytes);
    if (!validation.isValid) throw FormatException(validation.message);
    final envelope = _decodeEnvelope(bytes);
    state.restoreBackupMap(_asMap(envelope['payload']));
  }

  Map<String, dynamic> _decodeEnvelope(Uint8List bytes) {
    if (bytes.isEmpty) throw const FormatException('Backup kosong');
    final decoded = jsonDecode(utf8.decode(bytes));
    final envelope = _asMap(decoded);
    if (envelope['magic'] != magic) throw const FormatException('Magic backup tidak valid');
    if (envelope['version'] != version) throw const FormatException('Versi backup tidak didukung');
    if (envelope['checksum'] is! String || (envelope['checksum'] as String).length != 64) {
      throw const FormatException('Checksum backup tidak valid');
    }
    if (envelope['payload'] is! Map) throw const FormatException('Payload backup tidak valid');
    return envelope;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, value) => MapEntry(key.toString(), value));
    throw const FormatException('Backup bukan objek JSON');
  }
}

/// Short alias for callers that do not need to name the wire format.
typedef JsonBackupService = VersionedJsonBackupService;

/// Small self-contained SHA-256 implementation, avoiding a platform/package
/// dependency in the service layer.
class _Sha256 {
  static const _k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee,
    0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  static String hex(List<int> input) {
    final data = List<int>.from(input);
    final bitLength = data.length * 8;
    data.add(0x80);
    while (data.length % 64 != 56) data.add(0);
    for (var shift = 56; shift >= 0; shift -= 8) data.add((bitLength >> shift) & 0xff);
    var h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a;
    var h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19;
    int rotr(int value, int amount) => ((value >>> amount) | (value << (32 - amount))) & 0xffffffff;
    for (var offset = 0; offset < data.length; offset += 64) {
      final w = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        final p = offset + i * 4;
        w[i] = (data[p] << 24) | (data[p + 1] << 16) | (data[p + 2] << 8) | data[p + 3];
      }
      for (var i = 16; i < 64; i++) {
        final s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
      }
      var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, hh = h7;
      for (var i = 0; i < 64; i++) {
        final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = (hh + s1 + ch + _k[i] + w[i]) & 0xffffffff;
        final s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & 0xffffffff;
        hh = g; g = f; f = e; e = (d + temp1) & 0xffffffff;
        d = c; c = b; b = a; a = (temp1 + temp2) & 0xffffffff;
      }
      h0 = (h0 + a) & 0xffffffff; h1 = (h1 + b) & 0xffffffff; h2 = (h2 + c) & 0xffffffff; h3 = (h3 + d) & 0xffffffff;
      h4 = (h4 + e) & 0xffffffff; h5 = (h5 + f) & 0xffffffff; h6 = (h6 + g) & 0xffffffff; h7 = (h7 + hh) & 0xffffffff;
    }
    return [h0, h1, h2, h3, h4, h5, h6, h7].map((v) => v.toRadixString(16).padLeft(8, '0')).join();
  }
}
