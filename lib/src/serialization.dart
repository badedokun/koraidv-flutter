/// Kora IDV Flutter SDK — Serialization.
///
/// Map <-> model conversion helpers for the MethodChannel bridge.
/// Unlike the RN SDK which uses JSON strings, Flutter's StandardMethodCodec
/// natively supports Map<String, dynamic>, so we serialize to/from Maps.
library;

import 'types.dart';
import 'kora_exception.dart';

// ---------------------------------------------------------------------------
// Configuration -> Map (sent to native)
// ---------------------------------------------------------------------------

Map<String, dynamic> serializeConfiguration(KoraIDVConfiguration config) {
  final map = <String, dynamic>{
    'apiKey': config.apiKey,
    'tenantId': config.tenantId,
  };

  if (config.environment != null) {
    map['environment'] = config.environment!.value;
  }
  if (config.baseUrl != null) {
    map['baseUrl'] = config.baseUrl;
  }
  if (config.documentTypes != null) {
    map['documentTypes'] = config.documentTypes!.map((d) => d.code).toList();
  }
  if (config.livenessMode != null) {
    map['livenessMode'] = config.livenessMode!.value;
  }
  if (config.theme != null) {
    map['theme'] = serializeTheme(config.theme!);
  }
  if (config.timeout != null) {
    map['timeout'] = config.timeout;
  }
  if (config.debugLogging != null) {
    map['debugLogging'] = config.debugLogging;
  }

  return map;
}

Map<String, dynamic> serializeTheme(KoraTheme theme) {
  final map = <String, dynamic>{};
  if (theme.primaryColor != null) map['primaryColor'] = theme.primaryColor;
  if (theme.backgroundColor != null) map['backgroundColor'] = theme.backgroundColor;
  if (theme.surfaceColor != null) map['surfaceColor'] = theme.surfaceColor;
  if (theme.textColor != null) map['textColor'] = theme.textColor;
  if (theme.errorColor != null) map['errorColor'] = theme.errorColor;
  if (theme.successColor != null) map['successColor'] = theme.successColor;
  if (theme.cornerRadius != null) map['cornerRadius'] = theme.cornerRadius;
  if (theme.fontFamily != null) map['fontFamily'] = theme.fontFamily;
  return map;
}

// ---------------------------------------------------------------------------
// Map -> Verification result (received from native)
// ---------------------------------------------------------------------------

VerificationFlowResult deserializeResult(Map<String, dynamic> map) {
  final type = map['type'] as String?;

  if (type == 'cancelled') {
    return const VerificationCancelled();
  }

  if (type == 'success') {
    final verificationMap = map['verification'] as Map<String, dynamic>?;
    if (verificationMap == null) {
      throw KoraException(
        KoraErrorCode.invalidResponse,
        'Missing verification data in success result.',
      );
    }
    final verification = deserializeVerification(verificationMap);
    return VerificationSuccess(verification);
  }

  throw KoraException(
    KoraErrorCode.invalidResponse,
    'Unknown result type: $type',
  );
}

// ---------------------------------------------------------------------------
// Map -> KoraException (from PlatformException)
// ---------------------------------------------------------------------------

KoraException deserializeError(String code, String message) {
  final errorCode = KoraErrorCode.fromCode(code);
  return KoraException(errorCode, message);
}

// ---------------------------------------------------------------------------
// Verification deserialization
// ---------------------------------------------------------------------------

Verification deserializeVerification(Map<String, dynamic> map) {
  return Verification(
    id: map['id'] as String,
    externalId: map['externalId'] as String,
    tenantId: map['tenantId'] as String,
    tier: map['tier'] as String,
    status: VerificationStatus.fromString(map['status'] as String),
    documentVerification: map['documentVerification'] != null
        ? deserializeDocumentVerification(
            Map<String, dynamic>.from(map['documentVerification'] as Map))
        : null,
    faceVerification: map['faceVerification'] != null
        ? deserializeFaceVerification(
            Map<String, dynamic>.from(map['faceVerification'] as Map))
        : null,
    livenessVerification: map['livenessVerification'] != null
        ? deserializeLivenessVerification(
            Map<String, dynamic>.from(map['livenessVerification'] as Map))
        : null,
    riskSignals: map['riskSignals'] != null
        ? (map['riskSignals'] as List)
            .map((e) => deserializeRiskSignal(Map<String, dynamic>.from(e as Map)))
            .toList()
        : null,
    riskScore: (map['riskScore'] as num?)?.toDouble(),
    createdAt: map['createdAt'] as String,
    updatedAt: map['updatedAt'] as String,
    completedAt: map['completedAt'] as String?,
  );
}

DocumentVerification deserializeDocumentVerification(Map<String, dynamic> map) {
  return DocumentVerification(
    documentType: map['documentType'] as String,
    documentNumber: map['documentNumber'] as String?,
    firstName: map['firstName'] as String?,
    lastName: map['lastName'] as String?,
    dateOfBirth: map['dateOfBirth'] as String?,
    expirationDate: map['expirationDate'] as String?,
    issuingCountry: map['issuingCountry'] as String?,
    mrzValid: map['mrzValid'] as bool?,
    authenticityScore: (map['authenticityScore'] as num?)?.toDouble(),
    extractedFields: map['extractedFields'] != null
        ? Map<String, String>.from(map['extractedFields'] as Map)
        : null,
  );
}

FaceVerification deserializeFaceVerification(Map<String, dynamic> map) {
  return FaceVerification(
    matchScore: (map['matchScore'] as num).toDouble(),
    matchResult: map['matchResult'] as String,
    confidence: (map['confidence'] as num).toDouble(),
  );
}

LivenessVerification deserializeLivenessVerification(Map<String, dynamic> map) {
  return LivenessVerification(
    livenessScore: (map['livenessScore'] as num).toDouble(),
    isLive: map['isLive'] as bool,
    challengeResults: map['challengeResults'] != null
        ? (map['challengeResults'] as List)
            .map((e) => deserializeChallengeResult(Map<String, dynamic>.from(e as Map)))
            .toList()
        : null,
  );
}

ChallengeResult deserializeChallengeResult(Map<String, dynamic> map) {
  return ChallengeResult(
    type: map['type'] as String,
    passed: map['passed'] as bool,
    confidence: (map['confidence'] as num).toDouble(),
  );
}

RiskSignal deserializeRiskSignal(Map<String, dynamic> map) {
  return RiskSignal(
    code: map['code'] as String,
    severity: map['severity'] as String,
    message: map['message'] as String,
  );
}
