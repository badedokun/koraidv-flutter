/// Kora IDV Flutter SDK — VerificationFlow Widget.
///
/// Headless convenience widget that auto-starts a verification flow
/// and fires callbacks on completion, error, or cancellation.
/// Renders nothing — all UI is in the native layer.
///
/// Mirrors the RN SDK's VerificationFlow component.
library;

import 'package:flutter/widgets.dart';

import '../types.dart';
import '../kora_exception.dart';
import 'koraidv_provider.dart';
import 'koraidv_controller.dart';

class VerificationFlow extends StatefulWidget {
  /// Unique identifier for this user/verification.
  final String externalId;

  /// Verification tier (default: standard).
  final VerificationTier tier;

  /// Additional options.
  final StartVerificationOptions? options;

  /// Called when verification completes successfully.
  final void Function(Verification verification)? onComplete;

  /// Called when an error occurs.
  final void Function(KoraException error)? onError;

  /// Called when the user cancels.
  final VoidCallback? onCancel;

  const VerificationFlow({
    super.key,
    required this.externalId,
    this.tier = VerificationTier.standard,
    this.options,
    this.onComplete,
    this.onError,
    this.onCancel,
  });

  @override
  State<VerificationFlow> createState() => _VerificationFlowState();
}

class _VerificationFlowState extends State<VerificationFlow> {
  late final KoraIDVController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Defer to post-frame so the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = KoraIDVProvider.of(context);
      _controller.addListener(_onStateChanged);
      _startIfNeeded();
    });
  }

  void _startIfNeeded() {
    if (!_started) {
      _started = true;
      _controller.startVerification(
        externalId: widget.externalId,
        tier: widget.tier,
        options: widget.options,
      );
    }
  }

  void _onStateChanged() {
    final controller = _controller;
    if (controller.verification != null) {
      widget.onComplete?.call(controller.verification!);
    }
    if (controller.error != null) {
      widget.onError?.call(controller.error!);
    }
    if (controller.isCancelled) {
      widget.onCancel?.call();
    }
  }

  @override
  void dispose() {
    if (_started) {
      _controller.removeListener(_onStateChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Renders nothing — native layer handles all UI.
    return const SizedBox.shrink();
  }
}
