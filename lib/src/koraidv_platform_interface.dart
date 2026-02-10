/// Abstract interface for platform-specific implementations.
/// Allows swapping the real MethodChannel with a mock for testing.
library;

abstract class KoraIDVPlatform {
  static KoraIDVPlatform? _instance;

  /// The current platform implementation.
  ///
  /// Defaults to [MethodChannelKoraIDV] (set in koraidv.dart).
  /// Override in tests with a mock.
  static KoraIDVPlatform get instance {
    if (_instance == null) {
      throw StateError(
        'KoraIDVPlatform.instance has not been set. '
        'Ensure KoraIDV is imported before accessing the platform.',
      );
    }
    return _instance!;
  }

  static set instance(KoraIDVPlatform value) {
    _instance = value;
  }

  /// Configure the native SDK.
  Future<void> configure(Map<String, dynamic> config);

  /// Start a new verification flow. Returns the result map from native.
  Future<Map<String, dynamic>> startVerification({
    required String externalId,
    required String tier,
    Map<String, dynamic>? options,
  });

  /// Resume an existing verification. Returns the result map from native.
  Future<Map<String, dynamic>> resumeVerification({
    required String verificationId,
  });
}
