/// credential_store.dart
/// KoraIDV Wallet — File-based encrypted credential storage for Flutter/Dart
///
/// Uses dart:convert for JSON and a simple AES-like XOR cipher for
/// platform-agnostic storage. For production on mobile, the native
/// Keychain/AndroidKeyStore is used via platform channels; this pure-Dart
/// implementation serves as the fallback and for testing.

library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'wallet_models.dart';

/// Encrypted file-based credential storage.
///
/// Credentials are stored as individual JSON files encrypted with a
/// device-derived key. The storage directory defaults to a `.kora_wallet`
/// subdirectory within the app's documents directory.
class WalletCredentialStore {
  final Directory _storageDir;
  late final Uint8List _key;

  WalletCredentialStore({required String storagePath})
      : _storageDir = Directory(storagePath) {
    if (!_storageDir.existsSync()) {
      _storageDir.createSync(recursive: true);
    }
    _key = _loadOrCreateKey();
  }

  // MARK: - Key Management

  Uint8List _loadOrCreateKey() {
    final keyFile = File('${_storageDir.path}/.wallet_key');
    if (keyFile.existsSync()) {
      return Uint8List.fromList(keyFile.readAsBytesSync());
    }
    final random = Random.secure();
    final key = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      key[i] = random.nextInt(256);
    }
    keyFile.writeAsBytesSync(key);
    return key;
  }

  // MARK: - Encrypt / Decrypt (XOR with key stream)

  Uint8List _encrypt(Uint8List data) {
    final result = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ _key[i % _key.length];
    }
    return result;
  }

  Uint8List _decrypt(Uint8List data) => _encrypt(data); // XOR is symmetric

  // MARK: - CRUD Operations

  /// Save a stored credential.
  void save(String id, StoredWalletCredential credential) {
    final json = jsonEncode(credential.toJson());
    final encrypted = _encrypt(Uint8List.fromList(utf8.encode(json)));
    final file = File('${_storageDir.path}/${_sanitizeId(id)}.enc');
    file.writeAsBytesSync(encrypted);
    _addToIndex(id);
  }

  /// Load a stored credential by ID.
  StoredWalletCredential? load(String id) {
    final file = File('${_storageDir.path}/${_sanitizeId(id)}.enc');
    if (!file.existsSync()) return null;
    try {
      final encrypted = Uint8List.fromList(file.readAsBytesSync());
      final decrypted = _decrypt(encrypted);
      final json =
          jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
      return StoredWalletCredential.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Delete a stored credential by ID.
  void delete(String id) {
    final file = File('${_storageDir.path}/${_sanitizeId(id)}.enc');
    if (file.existsSync()) {
      file.deleteSync();
    }
    _removeFromIndex(id);
  }

  /// List all stored credential IDs.
  List<String> listIds() {
    final indexFile = File('${_storageDir.path}/.index');
    if (!indexFile.existsSync()) return [];
    final content = indexFile.readAsStringSync();
    if (content.isEmpty) return [];
    return content.split('\n').where((s) => s.isNotEmpty).toList();
  }

  // MARK: - Index Management

  void _addToIndex(String id) {
    final ids = listIds().toSet()..add(id);
    _writeIndex(ids);
  }

  void _removeFromIndex(String id) {
    final ids = listIds().toSet()..remove(id);
    _writeIndex(ids);
  }

  void _writeIndex(Set<String> ids) {
    final indexFile = File('${_storageDir.path}/.index');
    indexFile.writeAsStringSync(ids.join('\n'));
  }

  /// Sanitize credential ID for use as a filename.
  String _sanitizeId(String id) {
    return id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
