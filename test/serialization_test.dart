import 'package:flutter_test/flutter_test.dart';
import 'package:koraidv_flutter/koraidv_flutter.dart';
import 'package:koraidv_flutter/src/serialization.dart';

void main() {
  group('serializeConfiguration', () {
    test('serializes required fields', () {
      const config = KoraIDVConfiguration(
        apiKey: 'ck_live_test',
        tenantId: 'tenant-123',
      );

      final map = serializeConfiguration(config);

      expect(map['apiKey'], 'ck_live_test');
      expect(map['tenantId'], 'tenant-123');
      expect(map.containsKey('environment'), isFalse);
      expect(map.containsKey('baseUrl'), isFalse);
    });

    test('serializes all optional fields', () {
      const config = KoraIDVConfiguration(
        apiKey: 'ck_sandbox_test',
        tenantId: 'tenant-456',
        environment: KoraEnvironment.sandbox,
        baseUrl: 'https://api.custom.com',
        documentTypes: [DocumentType.internationalPassport],
        livenessMode: LivenessMode.passive,
        theme: KoraTheme(
          primaryColor: '#0000FF',
          backgroundColor: '#FFFFFF',
          cornerRadius: 16,
        ),
        timeout: 300,
        debugLogging: true,
      );

      final map = serializeConfiguration(config);

      expect(map['environment'], 'sandbox');
      expect(map['baseUrl'], 'https://api.custom.com');
      expect(map['documentTypes'], ['international_passport']);
      expect(map['livenessMode'], 'passive');
      expect(map['theme'], {
        'primaryColor': '#0000FF',
        'backgroundColor': '#FFFFFF',
        'cornerRadius': 16,
      });
      expect(map['timeout'], 300);
      expect(map['debugLogging'], true);
    });
  });

  group('deserializeResult', () {
    test('deserializes cancelled result', () {
      final result = deserializeResult({'type': 'cancelled'});
      expect(result, isA<VerificationCancelled>());
    });

    test('deserializes success result with minimal verification', () {
      final result = deserializeResult({
        'type': 'success',
        'verification': {
          'id': 'ver-001',
          'externalId': 'user-1',
          'tenantId': 'tenant-1',
          'tier': 'standard',
          'status': 'approved',
          'createdAt': '2026-01-15T10:00:00.000Z',
          'updatedAt': '2026-01-15T10:05:00.000Z',
        },
      });

      expect(result, isA<VerificationSuccess>());
      final success = result as VerificationSuccess;
      expect(success.verification.id, 'ver-001');
      expect(success.verification.externalId, 'user-1');
      expect(success.verification.status, VerificationStatus.approved);
      expect(success.verification.documentVerification, isNull);
      expect(success.verification.faceVerification, isNull);
      expect(success.verification.livenessVerification, isNull);
      expect(success.verification.riskSignals, isNull);
      expect(success.verification.riskScore, isNull);
      expect(success.verification.completedAt, isNull);
    });

    test('deserializes success result with full verification', () {
      final result = deserializeResult({
        'type': 'success',
        'verification': {
          'id': 'ver-002',
          'externalId': 'user-2',
          'tenantId': 'tenant-2',
          'tier': 'enhanced',
          'status': 'approved',
          'documentVerification': {
            'documentType': 'us_drivers_license',
            'documentNumber': 'D1234567',
            'firstName': 'John',
            'lastName': 'Doe',
            'dateOfBirth': '1990-01-15',
            'expirationDate': '2028-01-15',
            'issuingCountry': 'US',
            'mrzValid': true,
            'authenticityScore': 0.95,
            'extractedFields': {'address': '123 Main St'},
          },
          'faceVerification': {
            'matchScore': 0.98,
            'matchResult': 'match',
            'confidence': 0.99,
          },
          'livenessVerification': {
            'livenessScore': 0.97,
            'isLive': true,
            'challengeResults': [
              {'type': 'blink', 'passed': true, 'confidence': 0.95},
              {'type': 'turn_head', 'passed': true, 'confidence': 0.92},
            ],
          },
          'riskSignals': [
            {'code': 'LOW_LIGHT', 'severity': 'low', 'message': 'Low light conditions'},
          ],
          'riskScore': 15.0,
          'createdAt': '2026-01-15T10:00:00.000Z',
          'updatedAt': '2026-01-15T10:10:00.000Z',
          'completedAt': '2026-01-15T10:10:00.000Z',
        },
      });

      final v = (result as VerificationSuccess).verification;
      expect(v.id, 'ver-002');
      expect(v.tier, 'enhanced');

      // Document verification
      expect(v.documentVerification, isNotNull);
      expect(v.documentVerification!.documentType, 'us_drivers_license');
      expect(v.documentVerification!.documentNumber, 'D1234567');
      expect(v.documentVerification!.firstName, 'John');
      expect(v.documentVerification!.mrzValid, true);
      expect(v.documentVerification!.authenticityScore, 0.95);
      expect(v.documentVerification!.extractedFields, {'address': '123 Main St'});

      // Face verification
      expect(v.faceVerification, isNotNull);
      expect(v.faceVerification!.matchScore, 0.98);
      expect(v.faceVerification!.matchResult, 'match');
      expect(v.faceVerification!.confidence, 0.99);

      // Liveness verification
      expect(v.livenessVerification, isNotNull);
      expect(v.livenessVerification!.livenessScore, 0.97);
      expect(v.livenessVerification!.isLive, true);
      expect(v.livenessVerification!.challengeResults, hasLength(2));
      expect(v.livenessVerification!.challengeResults![0].type, 'blink');
      expect(v.livenessVerification!.challengeResults![0].passed, true);

      // Risk
      expect(v.riskSignals, hasLength(1));
      expect(v.riskSignals![0].code, 'LOW_LIGHT');
      expect(v.riskScore, 15.0);
      expect(v.completedAt, '2026-01-15T10:10:00.000Z');
    });

    test('throws on unknown result type', () {
      expect(
        () => deserializeResult({'type': 'unknown'}),
        throwsA(isA<KoraException>().having(
          (e) => e.code,
          'code',
          KoraErrorCode.invalidResponse,
        )),
      );
    });

    test('throws on missing verification in success result', () {
      expect(
        () => deserializeResult({'type': 'success'}),
        throwsA(isA<KoraException>().having(
          (e) => e.code,
          'code',
          KoraErrorCode.invalidResponse,
        )),
      );
    });
  });

  group('deserializeError', () {
    test('maps known error code', () {
      final error = deserializeError('NETWORK_ERROR', 'Connection failed');
      expect(error.code, KoraErrorCode.networkError);
      expect(error.message, 'Connection failed');
    });

    test('maps unknown error code to unknown', () {
      final error = deserializeError('SOME_RANDOM_CODE', 'Unknown issue');
      expect(error.code, KoraErrorCode.unknown);
      expect(error.message, 'Unknown issue');
    });
  });

  group('VerificationStatus', () {
    test('fromString parses all statuses', () {
      expect(VerificationStatus.fromString('pending'), VerificationStatus.pending);
      expect(VerificationStatus.fromString('document_required'), VerificationStatus.documentRequired);
      expect(VerificationStatus.fromString('selfie_required'), VerificationStatus.selfieRequired);
      expect(VerificationStatus.fromString('liveness_required'), VerificationStatus.livenessRequired);
      expect(VerificationStatus.fromString('processing'), VerificationStatus.processing);
      expect(VerificationStatus.fromString('approved'), VerificationStatus.approved);
      expect(VerificationStatus.fromString('rejected'), VerificationStatus.rejected);
      expect(VerificationStatus.fromString('review_required'), VerificationStatus.reviewRequired);
      expect(VerificationStatus.fromString('expired'), VerificationStatus.expired);
    });

    test('fromString defaults to pending for unknown', () {
      expect(VerificationStatus.fromString('xyz'), VerificationStatus.pending);
    });
  });

  group('DocumentType', () {
    test('fromCode parses all types', () {
      expect(DocumentType.fromCode('us_drivers_license'), DocumentType.usDriversLicense);
      expect(DocumentType.fromCode('ghana_card'), DocumentType.ghanaCard);
      expect(DocumentType.fromCode('international_passport'), DocumentType.internationalPassport);
    });

    test('fromCode returns null for unknown', () {
      expect(DocumentType.fromCode('unknown_doc'), isNull);
    });
  });

  group('KoraErrorCode', () {
    test('fromCode parses all 33 error codes', () {
      expect(KoraErrorCode.fromCode('NOT_CONFIGURED'), KoraErrorCode.notConfigured);
      expect(KoraErrorCode.fromCode('NETWORK_ERROR'), KoraErrorCode.networkError);
      expect(KoraErrorCode.fromCode('CAMERA_ACCESS_DENIED'), KoraErrorCode.cameraAccessDenied);
      expect(KoraErrorCode.fromCode('FACE_NOT_DETECTED'), KoraErrorCode.faceNotDetected);
      expect(KoraErrorCode.fromCode('LIVENESS_CHECK_FAILED'), KoraErrorCode.livenessCheckFailed);
      expect(KoraErrorCode.fromCode('VERIFICATION_EXPIRED'), KoraErrorCode.verificationExpired);
      expect(KoraErrorCode.fromCode('USER_CANCELLED'), KoraErrorCode.userCancelled);
      expect(KoraErrorCode.fromCode('NOT_IMPLEMENTED'), KoraErrorCode.notImplemented);
    });

    test('fromCode defaults to unknown', () {
      expect(KoraErrorCode.fromCode('GIBBERISH'), KoraErrorCode.unknown);
    });
  });
}
