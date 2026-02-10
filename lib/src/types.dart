/// Kora IDV Flutter SDK — Types.
///
/// All enums and model classes mirroring the React Native SDK's types.ts.
library;

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// SDK configuration.
class KoraIDVConfiguration {
  /// API key for authentication (starts with ck_live_, ck_sandbox_, kora_live_, or kora_sandbox_).
  final String apiKey;

  /// Tenant ID (UUID).
  final String tenantId;

  /// API environment (auto-detected from API key prefix if omitted).
  final KoraEnvironment? environment;

  /// Custom base URL override (e.g., for self-hosted deployments).
  final String? baseUrl;

  /// Allowed document types (default: all).
  final List<DocumentType>? documentTypes;

  /// Liveness detection mode (default: active).
  final LivenessMode? livenessMode;

  /// Custom theme for UI customization.
  final KoraTheme? theme;

  /// Session timeout in seconds (default: 600).
  final int? timeout;

  /// Enable debug logging (default: false).
  final bool? debugLogging;

  const KoraIDVConfiguration({
    required this.apiKey,
    required this.tenantId,
    this.environment,
    this.baseUrl,
    this.documentTypes,
    this.livenessMode,
    this.theme,
    this.timeout,
    this.debugLogging,
  });
}

// ---------------------------------------------------------------------------
// Environment
// ---------------------------------------------------------------------------

enum KoraEnvironment {
  production('production'),
  sandbox('sandbox');

  final String value;
  const KoraEnvironment(this.value);

  static KoraEnvironment fromString(String value) {
    return KoraEnvironment.values.firstWhere(
      (e) => e.value == value,
      orElse: () => KoraEnvironment.production,
    );
  }
}

// ---------------------------------------------------------------------------
// Document Types
// ---------------------------------------------------------------------------

enum DocumentType {
  // US Documents
  usDriversLicense('us_drivers_license'),
  usStateId('us_state_id'),
  usGreenCard('us_green_card'),

  // Passport (all countries)
  internationalPassport('international_passport'),

  // EU ID Cards
  euIdGermany('eu_id_de'),
  euIdFrance('eu_id_fr'),
  euIdSpain('eu_id_es'),
  euIdItaly('eu_id_it'),

  // Africa
  ghanaCard('ghana_card'),
  nigeriaNin('ng_nin'),
  kenyaId('ke_id'),
  southAfricaId('za_id');

  final String code;
  const DocumentType(this.code);

  static DocumentType? fromCode(String code) {
    for (final type in DocumentType.values) {
      if (type.code == code) return type;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Verification Tier
// ---------------------------------------------------------------------------

enum VerificationTier {
  basic('basic'),
  standard('standard'),
  enhanced('enhanced');

  final String value;
  const VerificationTier(this.value);

  static VerificationTier fromString(String value) {
    return VerificationTier.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerificationTier.standard,
    );
  }
}

// ---------------------------------------------------------------------------
// Verification Status
// ---------------------------------------------------------------------------

enum VerificationStatus {
  pending('pending'),
  documentRequired('document_required'),
  selfieRequired('selfie_required'),
  livenessRequired('liveness_required'),
  processing('processing'),
  approved('approved'),
  rejected('rejected'),
  reviewRequired('review_required'),
  expired('expired');

  final String value;
  const VerificationStatus(this.value);

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

// ---------------------------------------------------------------------------
// Liveness Mode
// ---------------------------------------------------------------------------

enum LivenessMode {
  active('active'),
  passive('passive');

  final String value;
  const LivenessMode(this.value);

  static LivenessMode fromString(String value) {
    return LivenessMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LivenessMode.active,
    );
  }
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

class KoraTheme {
  final String? primaryColor;
  final String? backgroundColor;
  final String? surfaceColor;
  final String? textColor;
  final String? errorColor;
  final String? successColor;
  final double? cornerRadius;
  final String? fontFamily;

  const KoraTheme({
    this.primaryColor,
    this.backgroundColor,
    this.surfaceColor,
    this.textColor,
    this.errorColor,
    this.successColor,
    this.cornerRadius,
    this.fontFamily,
  });
}

// ---------------------------------------------------------------------------
// Verification
// ---------------------------------------------------------------------------

class Verification {
  final String id;
  final String externalId;
  final String tenantId;
  final String tier;
  final VerificationStatus status;
  final DocumentVerification? documentVerification;
  final FaceVerification? faceVerification;
  final LivenessVerification? livenessVerification;
  final List<RiskSignal>? riskSignals;
  final double? riskScore;
  final String createdAt;
  final String updatedAt;
  final String? completedAt;

  const Verification({
    required this.id,
    required this.externalId,
    required this.tenantId,
    required this.tier,
    required this.status,
    this.documentVerification,
    this.faceVerification,
    this.livenessVerification,
    this.riskSignals,
    this.riskScore,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
}

// ---------------------------------------------------------------------------
// Document Verification
// ---------------------------------------------------------------------------

class DocumentVerification {
  final String documentType;
  final String? documentNumber;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? expirationDate;
  final String? issuingCountry;
  final bool? mrzValid;
  final double? authenticityScore;
  final Map<String, String>? extractedFields;

  const DocumentVerification({
    required this.documentType,
    this.documentNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.expirationDate,
    this.issuingCountry,
    this.mrzValid,
    this.authenticityScore,
    this.extractedFields,
  });
}

// ---------------------------------------------------------------------------
// Face Verification
// ---------------------------------------------------------------------------

class FaceVerification {
  final double matchScore;
  final String matchResult;
  final double confidence;

  const FaceVerification({
    required this.matchScore,
    required this.matchResult,
    required this.confidence,
  });
}

// ---------------------------------------------------------------------------
// Liveness Verification
// ---------------------------------------------------------------------------

class LivenessVerification {
  final double livenessScore;
  final bool isLive;
  final List<ChallengeResult>? challengeResults;

  const LivenessVerification({
    required this.livenessScore,
    required this.isLive,
    this.challengeResults,
  });
}

// ---------------------------------------------------------------------------
// Challenge Result
// ---------------------------------------------------------------------------

class ChallengeResult {
  final String type;
  final bool passed;
  final double confidence;

  const ChallengeResult({
    required this.type,
    required this.passed,
    required this.confidence,
  });
}

// ---------------------------------------------------------------------------
// Risk Signal
// ---------------------------------------------------------------------------

class RiskSignal {
  final String code;
  final String severity;
  final String message;

  const RiskSignal({
    required this.code,
    required this.severity,
    required this.message,
  });
}

// ---------------------------------------------------------------------------
// Verification Flow Result (sealed class)
// ---------------------------------------------------------------------------

sealed class VerificationFlowResult {
  const VerificationFlowResult();
}

class VerificationSuccess extends VerificationFlowResult {
  final Verification verification;
  const VerificationSuccess(this.verification);
}

class VerificationCancelled extends VerificationFlowResult {
  const VerificationCancelled();
}

// ---------------------------------------------------------------------------
// Start Verification Options
// ---------------------------------------------------------------------------

class StartVerificationOptions {
  /// Override document types for this verification.
  final List<DocumentType>? documentTypes;

  const StartVerificationOptions({this.documentTypes});
}
