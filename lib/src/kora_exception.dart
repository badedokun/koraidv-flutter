/// Kora IDV Flutter SDK — Exception types.
///
/// Mirrors the React Native SDK's KoraError and KoraErrorCode.
library;

// ---------------------------------------------------------------------------
// Error Codes
// ---------------------------------------------------------------------------

enum KoraErrorCode {
  // Configuration errors
  notConfigured('NOT_CONFIGURED'),
  invalidApiKey('INVALID_API_KEY'),
  invalidTenantId('INVALID_TENANT_ID'),

  // Network errors
  networkError('NETWORK_ERROR'),
  timeout('TIMEOUT'),
  noInternet('NO_INTERNET'),

  // HTTP errors
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  notFound('NOT_FOUND'),
  validationError('VALIDATION_ERROR'),
  rateLimited('RATE_LIMITED'),
  serverError('SERVER_ERROR'),
  httpError('HTTP_ERROR'),

  // Response errors
  invalidResponse('INVALID_RESPONSE'),
  noData('NO_DATA'),
  decodingError('DECODING_ERROR'),
  encodingError('ENCODING_ERROR'),

  // Capture errors
  cameraAccessDenied('CAMERA_ACCESS_DENIED'),
  cameraNotAvailable('CAMERA_NOT_AVAILABLE'),
  captureFailed('CAPTURE_FAILED'),
  qualityValidationFailed('QUALITY_VALIDATION_FAILED'),

  // Document errors
  documentNotDetected('DOCUMENT_NOT_DETECTED'),
  documentTypeNotSupported('DOCUMENT_TYPE_NOT_SUPPORTED'),
  mrzReadFailed('MRZ_READ_FAILED'),

  // Face errors
  faceNotDetected('FACE_NOT_DETECTED'),
  multipleFacesDetected('MULTIPLE_FACES_DETECTED'),
  faceMatchFailed('FACE_MATCH_FAILED'),

  // Liveness errors
  livenessCheckFailed('LIVENESS_CHECK_FAILED'),
  challengeNotCompleted('CHALLENGE_NOT_COMPLETED'),
  sessionExpired('SESSION_EXPIRED'),

  // Verification errors
  verificationExpired('VERIFICATION_EXPIRED'),
  verificationAlreadyCompleted('VERIFICATION_ALREADY_COMPLETED'),
  invalidVerificationState('INVALID_VERIFICATION_STATE'),

  // NFC errors
  nfcNotAvailable('NFC_NOT_AVAILABLE'),
  nfcReadFailed('NFC_READ_FAILED'),

  // Generic errors
  unknown('UNKNOWN'),
  userCancelled('USER_CANCELLED'),

  // Flutter specific
  notImplemented('NOT_IMPLEMENTED');

  final String code;
  const KoraErrorCode(this.code);

  static KoraErrorCode fromCode(String code) {
    for (final value in KoraErrorCode.values) {
      if (value.code == code) return value;
    }
    return KoraErrorCode.unknown;
  }
}

// ---------------------------------------------------------------------------
// Error Messages
// ---------------------------------------------------------------------------

const Map<KoraErrorCode, String> _errorMessages = {
  KoraErrorCode.notConfigured: 'SDK not configured. Call KoraIDV.configure() first.',
  KoraErrorCode.invalidApiKey: 'Invalid API key provided.',
  KoraErrorCode.invalidTenantId: 'Invalid tenant ID provided.',
  KoraErrorCode.networkError: 'Network error. Please check your connection.',
  KoraErrorCode.timeout: 'Request timed out. Please try again.',
  KoraErrorCode.noInternet: 'No internet connection.',
  KoraErrorCode.unauthorized: 'Authentication failed. Check your API key.',
  KoraErrorCode.forbidden: 'Access denied.',
  KoraErrorCode.notFound: 'Resource not found.',
  KoraErrorCode.validationError: 'Validation error.',
  KoraErrorCode.rateLimited: 'Rate limit exceeded. Please try again later.',
  KoraErrorCode.serverError: 'Server error. Please try again later.',
  KoraErrorCode.httpError: 'HTTP error occurred.',
  KoraErrorCode.invalidResponse: 'Invalid response from server.',
  KoraErrorCode.noData: 'No data received from server.',
  KoraErrorCode.decodingError: 'Failed to parse response.',
  KoraErrorCode.encodingError: 'Failed to encode request.',
  KoraErrorCode.cameraAccessDenied: 'Camera access denied. Please enable camera access in Settings.',
  KoraErrorCode.cameraNotAvailable: 'Camera not available on this device.',
  KoraErrorCode.captureFailed: 'Capture failed.',
  KoraErrorCode.qualityValidationFailed: 'Quality check failed.',
  KoraErrorCode.documentNotDetected: 'Document not detected. Position document in frame.',
  KoraErrorCode.documentTypeNotSupported: 'Document type not supported.',
  KoraErrorCode.mrzReadFailed: 'Could not read document MRZ.',
  KoraErrorCode.faceNotDetected: 'Face not detected. Position face in frame.',
  KoraErrorCode.multipleFacesDetected: 'Multiple faces detected. Show only one face.',
  KoraErrorCode.faceMatchFailed: 'Face match failed.',
  KoraErrorCode.livenessCheckFailed: 'Liveness check failed.',
  KoraErrorCode.challengeNotCompleted: 'Challenge not completed.',
  KoraErrorCode.sessionExpired: 'Session expired. Please start over.',
  KoraErrorCode.verificationExpired: 'Verification expired. Please start a new one.',
  KoraErrorCode.verificationAlreadyCompleted: 'Verification already completed.',
  KoraErrorCode.invalidVerificationState: 'Invalid verification state.',
  KoraErrorCode.unknown: 'An unknown error occurred.',
  KoraErrorCode.userCancelled: 'Verification cancelled.',
  KoraErrorCode.nfcNotAvailable: 'NFC is not available on this device.',
  KoraErrorCode.nfcReadFailed: 'Failed to read NFC chip from document.',
  KoraErrorCode.notImplemented: 'This feature is not yet implemented on this platform.',
};

// ---------------------------------------------------------------------------
// Recovery Suggestions
// ---------------------------------------------------------------------------

const Map<KoraErrorCode, String> _recoverySuggestions = {
  KoraErrorCode.cameraAccessDenied: 'Go to Settings and enable camera access for this app.',
  KoraErrorCode.noInternet: 'Check your Wi-Fi or cellular connection.',
  KoraErrorCode.timeout: 'Please wait a moment and try again.',
  KoraErrorCode.rateLimited: 'Please wait a moment and try again.',
  KoraErrorCode.serverError: 'Please wait a moment and try again.',
  KoraErrorCode.documentNotDetected: 'Place document on flat surface with good lighting.',
  KoraErrorCode.faceNotDetected: 'Ensure good lighting and center your face.',
  KoraErrorCode.qualityValidationFailed: 'Hold device steady and ensure good lighting.',
  KoraErrorCode.nfcNotAvailable: 'This device does not support NFC.',
  KoraErrorCode.nfcReadFailed: 'Hold the document flat against the back of your device and keep it still.',
};

// ---------------------------------------------------------------------------
// KoraException
// ---------------------------------------------------------------------------

class KoraException implements Exception {
  final KoraErrorCode code;
  final String message;
  final String? recoverySuggestion;

  KoraException(this.code, [String? message])
      : message = message ?? _errorMessages[code] ?? 'An error occurred',
        recoverySuggestion = _recoverySuggestions[code];

  bool get isRetryable => const [
        KoraErrorCode.networkError,
        KoraErrorCode.timeout,
        KoraErrorCode.rateLimited,
        KoraErrorCode.serverError,
      ].contains(code);

  @override
  String toString() => 'KoraException(${code.code}): $message';
}
