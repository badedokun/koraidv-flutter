/// wallet_qr_code.dart
/// KoraIDV Wallet — QR code deep link generation for credential presentations

library;

import 'dart:convert';

import 'selective_disclosure.dart';
import 'wallet_models.dart';

/// Generates deep links for Verifiable Presentations.
///
/// QR code image rendering is left to the consuming app (using packages like
/// `qr_flutter`). This class provides the data/URL to encode.
class WalletQRCode {
  static const int _maxInlineSize = 2048;

  /// Generate a deep link URI for the given presentation.
  ///
  /// If the JSON payload fits within 2 KB, it is base64url-encoded inline.
  /// Otherwise a reference link with credential ID and profile name is produced.
  static Uri? deepLink({
    required WalletPresentation presentation,
    DisclosureProfile profile = DisclosureProfile.full,
  }) {
    final json = jsonEncode(presentation.toJson());
    final data = utf8.encode(json);

    if (data.length <= _maxInlineSize) {
      final encoded = base64Url.encode(data).replaceAll('=', '');
      return Uri.parse('korastratum://present?data=$encoded');
    }

    // Fallback: reference link
    final credId = presentation.verifiableCredential.isNotEmpty
        ? presentation.verifiableCredential.first.id
        : 'unknown';
    final profileName = profile.name;
    return Uri.parse(
        'korastratum://present?ref=$credId&profile=$profileName');
  }

  /// Get the string content to encode in a QR code.
  ///
  /// Use this with a QR rendering package like `qr_flutter`:
  /// ```dart
  /// QrImageView(data: WalletQRCode.qrContent(presentation: vp));
  /// ```
  static String? qrContent({
    required WalletPresentation presentation,
    DisclosureProfile profile = DisclosureProfile.full,
  }) {
    final uri = deepLink(presentation: presentation, profile: profile);
    return uri?.toString();
  }
}
