/// Kora IDV Flutter SDK — Imperative Singleton API.
///
/// Mirrors the React Native SDK's KoraIDVModule.
/// Provides configure(), startVerification(), resumeVerification(), reset().
library;

import 'package:flutter/services.dart';

import 'types.dart';
import 'kora_exception.dart';
import 'serialization.dart';
import 'koraidv_platform_interface.dart';
import 'koraidv_method_channel.dart';

class KoraIDV {
  KoraIDV._() {
    // Register the default MethodChannel implementation.
    KoraIDVPlatform.instance = MethodChannelKoraIDV();
  }

  static final KoraIDV instance = KoraIDV._();

  bool _isConfigured = false;

  /// Whether the SDK has been configured.
  bool get isConfigured => _isConfigured;

  /// SDK version.
  String get version => '1.0.0';

  /// Configure the SDK. Must be called before starting any verification.
  Future<void> configure(KoraIDVConfiguration config) async {
    final map = serializeConfiguration(config);
    await KoraIDVPlatform.instance.configure(map);
    _isConfigured = true;
  }

  /// Start a new verification flow.
  ///
  /// Launches the native full-screen verification UI and returns the result.
  Future<VerificationFlowResult> startVerification({
    required String externalId,
    VerificationTier tier = VerificationTier.standard,
    StartVerificationOptions? options,
  }) async {
    if (!_isConfigured) {
      throw KoraException(KoraErrorCode.notConfigured);
    }

    try {
      final resultMap = await KoraIDVPlatform.instance.startVerification(
        externalId: externalId,
        tier: tier.value,
        options: options?.documentTypes != null
            ? {'documentTypes': options!.documentTypes!.map((d) => d.code).toList()}
            : null,
      );
      return deserializeResult(resultMap);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  /// Resume an existing verification.
  Future<VerificationFlowResult> resumeVerification({
    required String verificationId,
  }) async {
    if (!_isConfigured) {
      throw KoraException(KoraErrorCode.notConfigured);
    }

    try {
      final resultMap = await KoraIDVPlatform.instance.resumeVerification(
        verificationId: verificationId,
      );
      return deserializeResult(resultMap);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  /// Reset the SDK configuration.
  void reset() {
    _isConfigured = false;
  }

  KoraException _mapPlatformException(PlatformException e) {
    return deserializeError(e.code, e.message ?? 'An error occurred');
  }
}
