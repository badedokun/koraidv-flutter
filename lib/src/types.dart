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

  /// Per-request network timeout in seconds. Passed through to the native SDK;
  /// null uses the native env-aware default (60s sandbox / 30s production on
  /// Android; 120s on iOS). Set to override.
  final int? networkTimeoutSeconds;

  /// Enable debug logging (default: false).
  final bool? debugLogging;

  /// Result page mode (REQ-005). `simplified` shows only Success/Failed/Review
  /// with no scores. Overrides the tenant-level `result_page_mode` setting.
  final ResultPageMode? resultPageMode;

  /// Optional per-outcome copy overrides for the simplified result page.
  final ResultPageMessages? customMessages;

  /// Render Visual Guide illustrations above the capture + liveness
  /// viewfinders. Defaults to `true` here so Flutter consumers get the
  /// same guided-UX behavior as Web SDK consumers (which also defaults
  /// true). Pass `false` for a plain text-only flow.
  ///
  /// Mirrors `Configuration.showVisualGuides` on the native Android SDK
  /// (since v1.3.0) and iOS SDK (since v1.7.0 SwiftUI Canvas port).
  /// Native default is `false`; the Flutter wrapper opts integrators into
  /// the guides by default because Flutter UX-consumers expect the
  /// fuller flow out of the box (same rationale as the Web SDK default).
  final bool? showVisualGuides;

  const KoraIDVConfiguration({
    required this.apiKey,
    required this.tenantId,
    this.environment,
    this.baseUrl,
    this.documentTypes,
    this.livenessMode,
    this.theme,
    this.timeout,
    this.networkTimeoutSeconds,
    this.debugLogging,
    this.resultPageMode,
    this.customMessages,
    this.showVisualGuides,
  });
}

// ---------------------------------------------------------------------------
// Result Page Mode (REQ-005)
// ---------------------------------------------------------------------------

enum ResultPageMode {
  detailed('detailed'),
  simplified('simplified');

  final String value;
  const ResultPageMode(this.value);
}

class ResultPageMessages {
  final String? successTitle;
  final String? successMessage;
  final String? failedTitle;
  final String? failedMessage;
  final String? reviewTitle;
  final String? reviewMessage;

  const ResultPageMessages({
    this.successTitle,
    this.successMessage,
    this.failedTitle,
    this.failedMessage,
    this.reviewTitle,
    this.reviewMessage,
  });

  Map<String, dynamic> toMap() => {
        if (successTitle != null) 'successTitle': successTitle,
        if (successMessage != null) 'successMessage': successMessage,
        if (failedTitle != null) 'failedTitle': failedTitle,
        if (failedMessage != null) 'failedMessage': failedMessage,
        if (reviewTitle != null) 'reviewTitle': reviewTitle,
        if (reviewMessage != null) 'reviewMessage': reviewMessage,
      };
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

/// Supported document types.
///
/// Note: This is a convenience subset. The full list of supported document types
/// (270+) is available via the API. The Flutter SDK delegates to the native
/// iOS/Android SDKs which fetch types dynamically.
enum DocumentType {
  // US Documents
  usDriversLicense('us_drivers_license'),
  usStateId('us_state_id'),
  usGreenCard('us_green_card'),

  // Passport (covers all 197 ICAO-compliant countries)
  internationalPassport('international_passport'),

  // EU ID Cards
  euIdGermany('eu_id_de'),
  euIdFrance('eu_id_fr'),
  euIdSpain('eu_id_es'),
  euIdItaly('eu_id_it'),

  // Africa
  ghanaCard('ghana_card'),
  nigeriaNin('ng_nin'),
  nigeriaDriversLicense('ng_drivers_license'),
  ghanaDriversLicense('gh_drivers_license'),
  kenyaId('ke_id'),
  kenyaDriversLicense('ke_drivers_license'),
  southAfricaId('za_id'),
  southAfricaDriversLicense('za_drivers_license'),

  // Liberia
  liberiaId('lr_id'),
  liberiaDriversLicense('lr_drivers_license'),
  liberiaVotersCard('lr_voters_card'),

  // Sierra Leone
  sierraLeoneId('sl_id'),
  sierraLeoneDriversLicense('sl_drivers_license'),
  sierraLeoneVotersCard('sl_voters_card'),

  // Gambia
  gambiaId('gm_id'),
  gambiaDriversLicense('gm_drivers_license'),

  // Nigeria (additional)
  nigeriaVotersCard('ng_voters_card'),

  // UK
  ukDriversLicense('uk_drivers_license'),
  ukBRP('uk_brp'),

  // Canada
  canadaDriversLicense('ca_drivers_license'),
  canadaPRCard('ca_pr_card'),
  canadaNationalID('ca_national_id'),

  // EU Residence Permits
  germanyResidencePermit('de_rp'),
  franceResidencePermit('fr_rp'),
  italyResidencePermit('it_rp'),
  spainResidencePermit('es_rp'),
  irelandResidencePermit('ie_rp'),
  portugalResidencePermit('pt_rp'),
  swedenResidencePermit('se_rp'),
  denmarkResidencePermit('dk_rp'),
  norwayResidencePermit('no_rp'),
  finlandResidencePermit('fi_rp'),
  polandResidencePermit('pl_rp'),

  // India
  indiaDriversLicense('in_drivers_license');

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
  final NfcVerification? nfcVerification;
  final VerificationScores? scores;
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
    this.nfcVerification,
    this.scores,
    this.riskSignals,
    this.riskScore,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
}

// ---------------------------------------------------------------------------
// Verification Scores
// ---------------------------------------------------------------------------

/// Backend verification scores (0-100 scale).
class VerificationScores {
  final double documentQuality;
  final double documentAuth;
  final double faceMatch;
  final double liveness;
  final double nameMatch;
  final double dataConsistency;
  final double screening;
  final double overall;

  const VerificationScores({
    required this.documentQuality,
    required this.documentAuth,
    required this.faceMatch,
    required this.liveness,
    required this.nameMatch,
    required this.dataConsistency,
    required this.screening,
    required this.overall,
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
// NFC Verification
// ---------------------------------------------------------------------------

class NfcVerification {
  final bool chipAuthentic;
  final bool passiveAuthPassed;
  final bool? activeAuthPassed;
  final double dataIntegrityScore;
  final bool faceImageExtracted;
  final String? documentNumber;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? expirationDate;
  final String? nationality;

  const NfcVerification({
    required this.chipAuthentic,
    required this.passiveAuthPassed,
    this.activeAuthPassed,
    required this.dataIntegrityScore,
    required this.faceImageExtracted,
    this.documentNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.expirationDate,
    this.nationality,
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

  /// Expected first name from registration (for name matching).
  final String? expectedFirstName;

  /// Expected last name from registration (for name matching).
  final String? expectedLastName;

  const StartVerificationOptions({
    this.documentTypes,
    this.expectedFirstName,
    this.expectedLastName,
  });
}
