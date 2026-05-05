/// selective_disclosure.dart
/// KoraIDV Wallet — Selective disclosure profiles for Verifiable Presentations

library;

import 'wallet_models.dart';

// MARK: - Disclosure Claims

enum DisclosureClaim {
  fullName,
  dateOfBirth,
  nationality,
  verificationLevel,
  documentType,
  documentCountry,
  biometricMatch,
  livenessCheck,
  governmentDbVerified,
  verifiedAt,
  confidenceScore,
}

// MARK: - Disclosure Profile

enum DisclosureProfileType {
  full,
  onboarding,
  ageOnly,
  nationalityOnly,
  verificationOnly,
  custom,
}

class DisclosureProfile {
  final DisclosureProfileType type;
  final Set<DisclosureClaim>? customClaims;

  const DisclosureProfile._(this.type, [this.customClaims]);

  static const full = DisclosureProfile._(DisclosureProfileType.full);
  static const onboarding =
      DisclosureProfile._(DisclosureProfileType.onboarding);
  static const ageOnly = DisclosureProfile._(DisclosureProfileType.ageOnly);
  static const nationalityOnly =
      DisclosureProfile._(DisclosureProfileType.nationalityOnly);
  static const verificationOnly =
      DisclosureProfile._(DisclosureProfileType.verificationOnly);

  factory DisclosureProfile.custom(Set<DisclosureClaim> claims) {
    return DisclosureProfile._(DisclosureProfileType.custom, claims);
  }

  String get name => type.name;
}

// MARK: - Selective Disclosure Engine

class SelectiveDisclosureEngine {
  /// Apply a disclosure profile to a credential, returning a new credential
  /// containing only the disclosed claims in its subject.
  static WalletCredential apply(
      DisclosureProfile profile, WalletCredential credential) {
    final Set<DisclosureClaim> claims;
    switch (profile.type) {
      case DisclosureProfileType.full:
        // Dart has no spread on call args — Set.of takes the iterable
        // directly. (An earlier `Set.of(...DisclosureClaim.values)` was a
        // JS-style copy-paste that broke compilation; in-place fix on v1.5.0.)
        claims = Set.of(DisclosureClaim.values);
      case DisclosureProfileType.onboarding:
        claims = {
          DisclosureClaim.fullName,
          DisclosureClaim.dateOfBirth,
          DisclosureClaim.nationality,
          DisclosureClaim.verificationLevel,
          DisclosureClaim.documentType,
          DisclosureClaim.documentCountry,
        };
      case DisclosureProfileType.ageOnly:
        claims = {DisclosureClaim.dateOfBirth};
      case DisclosureProfileType.nationalityOnly:
        claims = {DisclosureClaim.nationality};
      case DisclosureProfileType.verificationOnly:
        claims = {
          DisclosureClaim.verificationLevel,
          DisclosureClaim.verifiedAt,
          DisclosureClaim.confidenceScore,
        };
      case DisclosureProfileType.custom:
        claims = profile.customClaims ?? {};
    }

    final subject = credential.credentialSubject;
    final disclosed = WalletCredentialSubject(
      id: subject.id,
      fullName:
          claims.contains(DisclosureClaim.fullName) ? subject.fullName : '',
      dateOfBirth: claims.contains(DisclosureClaim.dateOfBirth)
          ? subject.dateOfBirth
          : null,
      nationality: claims.contains(DisclosureClaim.nationality)
          ? subject.nationality
          : null,
      verificationLevel: claims.contains(DisclosureClaim.verificationLevel)
          ? subject.verificationLevel
          : '',
      documentType: claims.contains(DisclosureClaim.documentType)
          ? subject.documentType
          : '',
      documentCountry: claims.contains(DisclosureClaim.documentCountry)
          ? subject.documentCountry
          : '',
      biometricMatch: claims.contains(DisclosureClaim.biometricMatch) &&
          subject.biometricMatch,
      livenessCheck: claims.contains(DisclosureClaim.livenessCheck) &&
          subject.livenessCheck,
      governmentDbVerified:
          claims.contains(DisclosureClaim.governmentDbVerified) &&
              subject.governmentDbVerified,
      verifiedAt: claims.contains(DisclosureClaim.verifiedAt)
          ? subject.verifiedAt
          : '',
      confidenceScore: claims.contains(DisclosureClaim.confidenceScore)
          ? subject.confidenceScore
          : 0.0,
    );

    return credential.copyWith(credentialSubject: disclosed);
  }

  /// For ageOnly profile, compute whether the subject is over 18.
  static bool computeAgeOver18(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) return false;
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age >= 18;
    } catch (_) {
      return false;
    }
  }
}
