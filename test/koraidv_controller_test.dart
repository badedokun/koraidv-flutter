import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koraidv_flutter/koraidv_flutter.dart';
import 'mock_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockKoraIDVPlatform mockPlatform;
  late KoraIDVController controller;

  setUp(() async {
    mockPlatform = MockKoraIDVPlatform();
    // Access KoraIDV.instance first (triggers singleton constructor),
    // then override the platform with our mock.
    KoraIDV.instance.reset();
    KoraIDVPlatform.instance = mockPlatform;

    // Configure the singleton so startVerification doesn't throw NOT_CONFIGURED.
    await KoraIDV.instance.configure(const KoraIDVConfiguration(
      apiKey: 'ck_live_test',
      tenantId: 'tenant-123',
    ));

    controller = KoraIDVController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('KoraIDVController', () {
    test('initial state is idle', () {
      expect(controller.verification, isNull);
      expect(controller.error, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isCancelled, isFalse);
    });

    group('startVerification', () {
      test('transitions to loading then success', () async {
        final states = <bool>[];
        controller.addListener(() => states.add(controller.isLoading));

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
          },
        };

        await controller.startVerification(externalId: 'user-1');

        // First notification: isLoading = true, second: isLoading = false
        expect(states, [true, false]);
        expect(controller.verification, isNotNull);
        expect(controller.verification!.id, 'ver-1');
        expect(controller.verification!.status, VerificationStatus.approved);
        expect(controller.error, isNull);
        expect(controller.isCancelled, isFalse);
        expect(controller.isLoading, isFalse);
      });

      test('transitions to loading then cancelled', () async {
        mockPlatform.nextResult = {'type': 'cancelled'};

        await controller.startVerification(externalId: 'user-1');

        expect(controller.isCancelled, isTrue);
        expect(controller.verification, isNull);
        expect(controller.error, isNull);
        expect(controller.isLoading, isFalse);
      });

      test('transitions to loading then error on PlatformException', () async {
        mockPlatform.nextError = PlatformException(
          code: 'CAMERA_ACCESS_DENIED',
          message: 'Camera blocked',
        );

        await controller.startVerification(externalId: 'user-1');

        expect(controller.error, isNotNull);
        expect(controller.error!.code, KoraErrorCode.cameraAccessDenied);
        expect(controller.verification, isNull);
        expect(controller.isCancelled, isFalse);
        expect(controller.isLoading, isFalse);
      });

      test('clears previous state on new start', () async {
        // First: succeed
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
          },
        };
        await controller.startVerification(externalId: 'user-1');
        expect(controller.verification, isNotNull);

        // Second: cancel — previous verification should be cleared
        mockPlatform.nextResult = {'type': 'cancelled'};
        await controller.startVerification(externalId: 'user-2');

        expect(controller.verification, isNull);
        expect(controller.isCancelled, isTrue);
      });
    });

    group('resumeVerification', () {
      test('transitions to loading then success', () async {
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

        await controller.resumeVerification(verificationId: 'ver-1');

        expect(controller.verification, isNotNull);
        expect(controller.verification!.status, VerificationStatus.processing);
        expect(controller.error, isNull);
        expect(controller.isLoading, isFalse);
      });

      test('transitions to error on failure', () async {
        mockPlatform.nextError = PlatformException(
          code: 'VERIFICATION_EXPIRED',
          message: 'Expired',
        );

        await controller.resumeVerification(verificationId: 'ver-1');

        expect(controller.error, isNotNull);
        expect(controller.error!.code, KoraErrorCode.verificationExpired);
        expect(controller.verification, isNull);
        expect(controller.isLoading, isFalse);
      });
    });

    group('reset', () {
      test('clears all state', () async {
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
          },
        };
        await controller.startVerification(externalId: 'user-1');
        expect(controller.verification, isNotNull);

        controller.reset();

        expect(controller.verification, isNull);
        expect(controller.error, isNull);
        expect(controller.isLoading, isFalse);
        expect(controller.isCancelled, isFalse);
      });

      test('notifies listeners on reset', () async {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.reset();

        expect(notified, isTrue);
      });
    });
  });

  group('KoraException', () {
    test('isRetryable for network errors', () {
      expect(KoraException(KoraErrorCode.networkError).isRetryable, isTrue);
      expect(KoraException(KoraErrorCode.timeout).isRetryable, isTrue);
      expect(KoraException(KoraErrorCode.rateLimited).isRetryable, isTrue);
      expect(KoraException(KoraErrorCode.serverError).isRetryable, isTrue);
    });

    test('isRetryable false for non-network errors', () {
      expect(KoraException(KoraErrorCode.notConfigured).isRetryable, isFalse);
      expect(KoraException(KoraErrorCode.cameraAccessDenied).isRetryable, isFalse);
      expect(KoraException(KoraErrorCode.unknown).isRetryable, isFalse);
    });

    test('has recovery suggestion for applicable codes', () {
      final e = KoraException(KoraErrorCode.cameraAccessDenied);
      expect(e.recoverySuggestion, isNotNull);
      expect(e.recoverySuggestion, contains('Settings'));
    });

    test('has default message from error code', () {
      final e = KoraException(KoraErrorCode.notConfigured);
      expect(e.message, contains('configure'));
    });

    test('uses custom message when provided', () {
      final e = KoraException(KoraErrorCode.unknown, 'Custom msg');
      expect(e.message, 'Custom msg');
    });

    test('toString includes code and message', () {
      final e = KoraException(KoraErrorCode.networkError, 'Oops');
      expect(e.toString(), 'KoraException(NETWORK_ERROR): Oops');
    });
  });
}
