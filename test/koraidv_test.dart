import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koraidv_flutter/koraidv_flutter.dart';
import 'mock_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockKoraIDVPlatform mockPlatform;
  late KoraIDV sut;

  setUp(() {
    sut = KoraIDV.instance;
    mockPlatform = MockKoraIDVPlatform();
    KoraIDVPlatform.instance = mockPlatform;
    sut.reset();
  });

  group('KoraIDV', () {
    test('version returns 1.0.0', () {
      expect(sut.version, '1.0.0');
    });

    test('isConfigured is false initially', () {
      expect(sut.isConfigured, isFalse);
    });

    group('configure', () {
      test('calls platform configure and sets isConfigured', () async {
        await sut.configure(const KoraIDVConfiguration(
          apiKey: 'ck_live_test',
          tenantId: 'tenant-123',
        ));

        expect(sut.isConfigured, isTrue);
        expect(mockPlatform.configureCalls, hasLength(1));
        expect(mockPlatform.configureCalls.first['apiKey'], 'ck_live_test');
        expect(mockPlatform.configureCalls.first['tenantId'], 'tenant-123');
      });

      test('serializes all configuration options', () async {
        await sut.configure(const KoraIDVConfiguration(
          apiKey: 'ck_sandbox_test',
          tenantId: 'tenant-456',
          environment: KoraEnvironment.sandbox,
          baseUrl: 'https://custom.api.com',
          documentTypes: [DocumentType.usDriversLicense, DocumentType.ghanaCard],
          livenessMode: LivenessMode.passive,
          theme: KoraTheme(primaryColor: '#FF0000'),
          timeout: 300,
          debugLogging: true,
        ));

        final config = mockPlatform.configureCalls.first;
        expect(config['environment'], 'sandbox');
        expect(config['baseUrl'], 'https://custom.api.com');
        expect(config['documentTypes'], ['us_drivers_license', 'ghana_card']);
        expect(config['livenessMode'], 'passive');
        expect(config['theme'], {'primaryColor': '#FF0000'});
        expect(config['timeout'], 300);
        expect(config['debugLogging'], true);
      });
    });

    group('startVerification', () {
      setUp(() async {
        await sut.configure(const KoraIDVConfiguration(
          apiKey: 'ck_live_test',
          tenantId: 'tenant-123',
        ));
      });

      test('throws KoraException if not configured', () async {
        sut.reset();
        expect(
          () => sut.startVerification(externalId: 'user-1'),
          throwsA(isA<KoraException>().having(
            (e) => e.code,
            'code',
            KoraErrorCode.notConfigured,
          )),
        );
      });

      test('returns VerificationSuccess on success result', () async {
        mockPlatform.nextResult = {
          'type': 'success',
          'verification': {
            'id': 'ver-1',
            'externalId': 'user-1',
            'tenantId': 'tenant-123',
            'tier': 'standard',
            'status': 'approved',
            'createdAt': '2026-01-15T10:00:00.000Z',
            'updatedAt': '2026-01-15T10:05:00.000Z',
            'completedAt': '2026-01-15T10:05:00.000Z',
          },
        };

        final result = await sut.startVerification(externalId: 'user-1');

        expect(result, isA<VerificationSuccess>());
        final success = result as VerificationSuccess;
        expect(success.verification.id, 'ver-1');
        expect(success.verification.status, VerificationStatus.approved);
      });

      test('returns VerificationCancelled on cancelled result', () async {
        mockPlatform.nextResult = {'type': 'cancelled'};

        final result = await sut.startVerification(externalId: 'user-1');

        expect(result, isA<VerificationCancelled>());
      });

      test('maps PlatformException to KoraException', () async {
        mockPlatform.nextError = PlatformException(
          code: 'NETWORK_ERROR',
          message: 'Connection failed',
        );

        expect(
          () => sut.startVerification(externalId: 'user-1'),
          throwsA(isA<KoraException>().having(
            (e) => e.code,
            'code',
            KoraErrorCode.networkError,
          )),
        );
      });

      test('passes externalId and tier to platform', () async {
        mockPlatform.nextResult = {'type': 'cancelled'};

        await sut.startVerification(
          externalId: 'user-1',
          tier: VerificationTier.enhanced,
        );

        expect(mockPlatform.startVerificationCalls, hasLength(1));
        final call = mockPlatform.startVerificationCalls.first;
        expect(call['externalId'], 'user-1');
        expect(call['tier'], 'enhanced');
      });
    });

    group('resumeVerification', () {
      setUp(() async {
        await sut.configure(const KoraIDVConfiguration(
          apiKey: 'ck_live_test',
          tenantId: 'tenant-123',
        ));
      });

      test('throws KoraException if not configured', () async {
        sut.reset();
        expect(
          () => sut.resumeVerification(verificationId: 'ver-1'),
          throwsA(isA<KoraException>().having(
            (e) => e.code,
            'code',
            KoraErrorCode.notConfigured,
          )),
        );
      });

      test('returns VerificationSuccess on success result', () async {
        mockPlatform.nextResult = {
          'type': 'success',
          'verification': {
            'id': 'ver-1',
            'externalId': 'user-1',
            'tenantId': 'tenant-123',
            'tier': 'standard',
            'status': 'processing',
            'createdAt': '2026-01-15T10:00:00.000Z',
            'updatedAt': '2026-01-15T10:05:00.000Z',
          },
        };

        final result = await sut.resumeVerification(verificationId: 'ver-1');

        expect(result, isA<VerificationSuccess>());
        expect(mockPlatform.resumeVerificationCalls, ['ver-1']);
      });

      test('maps PlatformException to KoraException', () async {
        mockPlatform.nextError = PlatformException(
          code: 'UNAUTHORIZED',
          message: 'Bad API key',
        );

        expect(
          () => sut.resumeVerification(verificationId: 'ver-1'),
          throwsA(isA<KoraException>().having(
            (e) => e.code,
            'code',
            KoraErrorCode.unauthorized,
          )),
        );
      });
    });

    group('reset', () {
      test('sets isConfigured to false', () async {
        await sut.configure(const KoraIDVConfiguration(
          apiKey: 'ck_live_test',
          tenantId: 'tenant-123',
        ));
        expect(sut.isConfigured, isTrue);

        sut.reset();
        expect(sut.isConfigured, isFalse);
      });
    });
  });
}
