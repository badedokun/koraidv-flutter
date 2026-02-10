/// Kora IDV Flutter SDK — Controller (ChangeNotifier).
///
/// State management for verification flows.
/// Mirrors the RN SDK's useKoraIDV hook state machine:
///   idle -> loading -> (success | error | cancelled)
library;

import 'package:flutter/foundation.dart';

import '../types.dart';
import '../kora_exception.dart';
import '../koraidv.dart';

class KoraIDVController extends ChangeNotifier {
  Verification? _verification;
  KoraException? _error;
  bool _isLoading = false;
  bool _isCancelled = false;

  /// Latest successful verification result.
  Verification? get verification => _verification;

  /// Latest error (null if none).
  KoraException? get error => _error;

  /// Whether a verification flow is currently in progress.
  bool get isLoading => _isLoading;

  /// Whether the user cancelled the last verification.
  bool get isCancelled => _isCancelled;

  /// Start a new verification flow.
  Future<void> startVerification({
    required String externalId,
    VerificationTier tier = VerificationTier.standard,
    StartVerificationOptions? options,
  }) async {
    _isLoading = true;
    _error = null;
    _isCancelled = false;
    _verification = null;
    notifyListeners();

    try {
      final result = await KoraIDV.instance.startVerification(
        externalId: externalId,
        tier: tier,
        options: options,
      );

      switch (result) {
        case VerificationSuccess(:final verification):
          _verification = verification;
        case VerificationCancelled():
          _isCancelled = true;
      }
    } on KoraException catch (e) {
      _error = e;
    } catch (e) {
      _error = KoraException(KoraErrorCode.unknown, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resume an existing verification.
  Future<void> resumeVerification({
    required String verificationId,
  }) async {
    _isLoading = true;
    _error = null;
    _isCancelled = false;
    _verification = null;
    notifyListeners();

    try {
      final result = await KoraIDV.instance.resumeVerification(
        verificationId: verificationId,
      );

      switch (result) {
        case VerificationSuccess(:final verification):
          _verification = verification;
        case VerificationCancelled():
          _isCancelled = true;
      }
    } on KoraException catch (e) {
      _error = e;
    } catch (e) {
      _error = KoraException(KoraErrorCode.unknown, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset state back to idle.
  void reset() {
    _verification = null;
    _error = null;
    _isLoading = false;
    _isCancelled = false;
    notifyListeners();
  }
}
