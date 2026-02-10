/// Kora IDV Flutter SDK — Provider Widget.
///
/// InheritedWidget that configures the SDK and provides [KoraIDVController]
/// to descendant widgets. Mirrors the RN SDK's KoraIDVProvider.
library;

import 'package:flutter/widgets.dart';

import '../types.dart';
import '../koraidv.dart';
import 'koraidv_controller.dart';

class KoraIDVProvider extends StatefulWidget {
  /// API key for authentication.
  final String apiKey;

  /// Tenant ID.
  final String tenantId;

  /// Additional configuration options.
  final KoraEnvironment? environment;
  final String? baseUrl;
  final List<DocumentType>? documentTypes;
  final LivenessMode? livenessMode;
  final KoraTheme? theme;
  final int? timeout;
  final bool? debugLogging;

  /// Child widget tree.
  final Widget child;

  const KoraIDVProvider({
    super.key,
    required this.apiKey,
    required this.tenantId,
    this.environment,
    this.baseUrl,
    this.documentTypes,
    this.livenessMode,
    this.theme,
    this.timeout,
    this.debugLogging,
    required this.child,
  });

  /// Access the [KoraIDVController] from the nearest ancestor [KoraIDVProvider].
  ///
  /// Throws if no [KoraIDVProvider] is found in the widget tree.
  static KoraIDVController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_KoraIDVScope>();
    if (scope == null) {
      throw FlutterError(
        'KoraIDVProvider.of() called with a context that does not contain a KoraIDVProvider.\n'
        'Ensure your widget is a descendant of KoraIDVProvider.',
      );
    }
    return scope.controller;
  }

  @override
  State<KoraIDVProvider> createState() => _KoraIDVProviderState();
}

class _KoraIDVProviderState extends State<KoraIDVProvider> {
  late final KoraIDVController _controller;
  bool _configured = false;

  @override
  void initState() {
    super.initState();
    _controller = KoraIDVController();
    _configure();
  }

  @override
  void didUpdateWidget(KoraIDVProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiKey != widget.apiKey ||
        oldWidget.tenantId != widget.tenantId) {
      _configure();
    }
  }

  Future<void> _configure() async {
    final config = KoraIDVConfiguration(
      apiKey: widget.apiKey,
      tenantId: widget.tenantId,
      environment: widget.environment,
      baseUrl: widget.baseUrl,
      documentTypes: widget.documentTypes,
      livenessMode: widget.livenessMode,
      theme: widget.theme,
      timeout: widget.timeout,
      debugLogging: widget.debugLogging,
    );
    await KoraIDV.instance.configure(config);
    if (mounted) {
      setState(() => _configured = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KoraIDVScope(
      isConfigured: _configured,
      controller: _controller,
      child: widget.child,
    );
  }
}

class _KoraIDVScope extends InheritedWidget {
  final bool isConfigured;
  final KoraIDVController controller;

  const _KoraIDVScope({
    required this.isConfigured,
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_KoraIDVScope oldWidget) {
    return isConfigured != oldWidget.isConfigured ||
        controller != oldWidget.controller;
  }
}
