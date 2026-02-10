import 'package:flutter/material.dart';
import 'package:koraidv_flutter/koraidv_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KoraIDVProvider(
      apiKey: 'ck_sandbox_your_key_here',
      tenantId: 'your-tenant-id-here',
      environment: KoraEnvironment.sandbox,
      debugLogging: true,
      child: MaterialApp(
        title: 'KoraIDV Flutter Example',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6750A4),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KoraIDV Flutter Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kora IDV Identity Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tap a button below to start a verification flow.'),
            const SizedBox(height: 32),

            // Example 1: Imperative API
            ElevatedButton(
              onPressed: () => _startImperative(context),
              child: const Text('Start Verification (Imperative)'),
            ),
            const SizedBox(height: 16),

            // Example 2: Controller-based
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ControllerExample()),
                );
              },
              child: const Text('Start Verification (Controller)'),
            ),
            const SizedBox(height: 16),

            // Example 3: VerificationFlow widget
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FlowWidgetExample()),
                );
              },
              child: const Text('Start Verification (Flow Widget)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startImperative(BuildContext context) async {
    try {
      final result = await KoraIDV.instance.startVerification(
        externalId: 'user-${DateTime.now().millisecondsSinceEpoch}',
        tier: VerificationTier.standard,
      );

      if (!context.mounted) return;

      switch (result) {
        case VerificationSuccess(:final verification):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verified: ${verification.status.value}')),
          );
        case VerificationCancelled():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification cancelled')),
          );
      }
    } on KoraException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }
}

/// Example using [KoraIDVController] directly.
class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample> {
  late final KoraIDVController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KoraIDVProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controller Example')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.verification != null) {
            final v = _controller.verification!;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text('Status: ${v.status.value}'),
                  Text('ID: ${v.id}'),
                ],
              ),
            );
          }
          if (_controller.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_controller.error!.message),
                  if (_controller.error!.recoverySuggestion != null)
                    Text(_controller.error!.recoverySuggestion!),
                ],
              ),
            );
          }
          if (_controller.isCancelled) {
            return const Center(child: Text('Verification was cancelled.'));
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => _controller.startVerification(
                externalId: 'user-${DateTime.now().millisecondsSinceEpoch}',
              ),
              child: const Text('Start Verification'),
            ),
          );
        },
      ),
    );
  }
}

/// Example using [VerificationFlow] headless widget.
class FlowWidgetExample extends StatelessWidget {
  const FlowWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flow Widget Example')),
      body: VerificationFlow(
        externalId: 'user-${DateTime.now().millisecondsSinceEpoch}',
        tier: VerificationTier.standard,
        onComplete: (verification) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Complete: ${verification.status.value}')),
          );
          Navigator.of(context).pop();
        },
        onError: (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.message}')),
          );
          Navigator.of(context).pop();
        },
        onCancel: () {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cancelled')),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
