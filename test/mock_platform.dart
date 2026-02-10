/// Mock [KoraIDVPlatform] for unit testing.
///
/// Records method calls and returns configurable responses.
library;

import 'package:koraidv_flutter/src/koraidv_platform_interface.dart';

class MockKoraIDVPlatform extends KoraIDVPlatform {
  /// Recorded configure calls.
  final List<Map<String, dynamic>> configureCalls = [];

  /// Recorded startVerification calls.
  final List<Map<String, dynamic>> startVerificationCalls = [];

  /// Recorded resumeVerification calls.
  final List<String> resumeVerificationCalls = [];

  /// Result to return from startVerification/resumeVerification.
  Map<String, dynamic>? nextResult;

  /// Error to throw from startVerification/resumeVerification.
  Exception? nextError;

  @override
  Future<void> configure(Map<String, dynamic> config) async {
    configureCalls.add(config);
  }

  @override
  Future<Map<String, dynamic>> startVerification({
    required String externalId,
    required String tier,
    Map<String, dynamic>? options,
  }) async {
    startVerificationCalls.add({
      'externalId': externalId,
      'tier': tier,
      if (options != null) 'options': options,
    });
    if (nextError != null) throw nextError!;
    return nextResult ?? {};
  }

  @override
  Future<Map<String, dynamic>> resumeVerification({
    required String verificationId,
  }) async {
    resumeVerificationCalls.add(verificationId);
    if (nextError != null) throw nextError!;
    return nextResult ?? {};
  }

  void reset() {
    configureCalls.clear();
    startVerificationCalls.clear();
    resumeVerificationCalls.clear();
    nextResult = null;
    nextError = null;
  }
}
