/// kora_wallet.dart
/// KoraIDV Wallet — Main wallet class for Flutter/Dart

library;

import 'credential_store.dart';
import 'selective_disclosure.dart';
import 'verifiable_presentation.dart';
import 'wallet_models.dart';
import 'wallet_qr_code.dart';

export 'selective_disclosure.dart';
export 'wallet_models.dart';
export 'wallet_qr_code.dart';

/// Main entry point for the Kora Wallet SDK module in Flutter.
///
/// Provides credential storage (file-based encrypted), selective disclosure,
/// Verifiable Presentation creation, and deep-link sharing.
class KoraWallet {
  final WalletCredentialStore _store;

  /// Create a new KoraWallet instance.
  ///
  /// [storagePath] should point to a secure, app-private directory.
  /// On mobile, use the application documents directory.
  KoraWallet({required String storagePath})
      : _store = WalletCredentialStore(storagePath: storagePath);

  // MARK: - Credential Management

  /// Store a Verifiable Credential in the wallet.
  ///
  /// Returns the storage ID (same as the credential's `id`).
  String store({required WalletCredential credential}) {
    final now = DateTime.now().toUtc().toIso8601String();
    final stored = StoredWalletCredential(
      id: credential.id,
      credential: credential,
      storedAt: now,
      issuerDID: credential.issuer,
      subjectName: credential.credentialSubject.fullName,
      expiresAt: credential.expirationDate,
    );
    _store.save(credential.id, stored);
    return credential.id;
  }

  /// Retrieve all stored credentials.
  List<StoredWalletCredential> getCredentials() {
    final ids = _store.listIds();
    return ids
        .map(_store.load)
        .where((c) => c != null)
        .cast<StoredWalletCredential>()
        .toList();
  }

  /// Retrieve a single credential by ID.
  StoredWalletCredential? getCredential(String id) {
    return _store.load(id);
  }

  /// Delete a credential from the wallet.
  void deleteCredential(String id) {
    _store.delete(id);
  }

  /// Number of credentials currently stored.
  int get credentialCount => _store.listIds().length;

  // MARK: - Presentation

  /// Create a Verifiable Presentation with selective disclosure.
  WalletPresentation createPresentation({
    required String credentialId,
    required DisclosureProfile profile,
    String? audience,
    String? nonce,
  }) {
    final stored = _store.load(credentialId);
    if (stored == null) {
      throw WalletException.credentialNotFound;
    }
    if (isExpired(credentialId)) {
      throw WalletException.credentialExpired;
    }
    return WalletPresentationBuilder.create(
      credential: stored.credential,
      profile: profile,
      audience: audience,
      nonce: nonce,
    );
  }

  /// Generate a deep link URI for sharing a presentation.
  Uri? generateDeepLink({
    required WalletPresentation presentation,
    DisclosureProfile profile = DisclosureProfile.full,
  }) {
    return WalletQRCode.deepLink(
        presentation: presentation, profile: profile);
  }

  // MARK: - Expiry

  /// Check whether a stored credential has expired.
  bool isExpired(String credentialId) {
    final stored = _store.load(credentialId);
    if (stored == null) return true;
    try {
      final expires = DateTime.parse(stored.expiresAt);
      return DateTime.now().toUtc().isAfter(expires);
    } catch (_) {
      return false;
    }
  }
}
