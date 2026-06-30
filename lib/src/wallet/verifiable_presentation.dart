/// verifiable_presentation.dart
/// KoraIDV Wallet — VP creation with selective disclosure

library;

import 'dart:convert';

import 'selective_disclosure.dart';
import 'wallet_models.dart';

/// Factory for building W3C Verifiable Presentations.
class WalletPresentationBuilder {
  /// Create a Verifiable Presentation from a credential with selective disclosure.
  static WalletPresentation create({
    required WalletCredential credential,
    required DisclosureProfile profile,
    String? holder,
    String? audience,
    String? nonce,
  }) {
    final disclosed = SelectiveDisclosureEngine.apply(profile, credential);
    final now = DateTime.now().toUtc().toIso8601String();

    return WalletPresentation(
      context: const ['https://www.w3.org/ns/credentials/v2'],
      type: const ['VerifiablePresentation'],
      holder: holder,
      verifiableCredential: [disclosed],
      created: now,
      audience: audience,
      challenge: nonce,
    );
  }

  /// Serialize a presentation to a JSON string.
  static String encode(WalletPresentation presentation) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(presentation.toJson());
  }

  /// Deserialize a presentation from a JSON string.
  static WalletPresentation decode(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return WalletPresentation.fromJson(map);
  }
}
