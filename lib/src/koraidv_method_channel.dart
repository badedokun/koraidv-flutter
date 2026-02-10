/// Kora IDV Flutter SDK — MethodChannel Implementation.
///
/// Real platform implementation that communicates with native iOS/Android
/// via Flutter's MethodChannel.
library;

import 'package:flutter/services.dart';

import 'koraidv_platform_interface.dart';

class MethodChannelKoraIDV extends KoraIDVPlatform {
  static const _channel = MethodChannel('com.koraidv.flutter/koraidv');

  @override
  Future<void> configure(Map<String, dynamic> config) async {
    await _channel.invokeMethod<void>('configure', config);
  }

  @override
  Future<Map<String, dynamic>> startVerification({
    required String externalId,
    required String tier,
    Map<String, dynamic>? options,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'startVerification',
      <String, dynamic>{
        'externalId': externalId,
        'tier': tier,
        if (options != null) ...options,
      },
    );
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> resumeVerification({
    required String verificationId,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'resumeVerification',
      <String, dynamic>{
        'verificationId': verificationId,
      },
    );
    return result ?? {};
  }
}
