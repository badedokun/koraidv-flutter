# koraidv_flutter

Kora IDV Identity Verification SDK for Flutter.

Thin wrapper over the native iOS and Android KoraIDV SDKs via platform channels. All camera capture, ML processing, liveness detection, and API communication stays in the native layer.

## Requirements

- Flutter 3.10+
- Dart 3.0+
- iOS 14.0+
- Android API 24+ (Android 7.0+)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  koraidv_flutter: ^1.0.0
```

### iOS

Add to your `ios/Podfile`:

```ruby
platform :ios, '14.0'
```

Run `pod install` from the `ios/` directory.

### Android

Add JitPack to your `android/build.gradle`:

```groovy
allprojects {
    repositories {
        // ...
        maven { url 'https://jitpack.io' }
    }
}
```

## Quick Start

### 1. Wrap your app with KoraIDVProvider

```dart
import 'package:koraidv_flutter/koraidv_flutter.dart';

void main() {
  runApp(
    KoraIDVProvider(
      apiKey: 'ck_live_your_key',
      tenantId: 'your-tenant-id',
      child: const MyApp(),
    ),
  );
}
```

### 2. Start a verification (Imperative API)

```dart
try {
  final result = await KoraIDV.instance.startVerification(
    externalId: 'user-123',
    tier: VerificationTier.standard,
  );

  switch (result) {
    case VerificationSuccess(:final verification):
      print('Verified: ${verification.status.value}');
    case VerificationCancelled():
      print('User cancelled');
  }
} on KoraException catch (e) {
  print('Error: ${e.message}');
}
```

### 3. Start a verification (Controller)

```dart
final controller = KoraIDVProvider.of(context);
controller.addListener(() {
  if (controller.verification != null) {
    print('Success: ${controller.verification!.status.value}');
  }
  if (controller.error != null) {
    print('Error: ${controller.error!.message}');
  }
  if (controller.isCancelled) {
    print('Cancelled');
  }
});

controller.startVerification(externalId: 'user-123');
```

### 4. Start a verification (VerificationFlow widget)

```dart
VerificationFlow(
  externalId: 'user-123',
  onComplete: (verification) => print('Done: ${verification.id}'),
  onError: (error) => print('Error: ${error.code}'),
  onCancel: () => print('Cancelled'),
)
```

## API Reference

### KoraIDV (Singleton)

| Method | Description |
|--------|-------------|
| `configure(KoraIDVConfiguration)` | Configure the SDK |
| `startVerification(...)` | Start a new verification flow |
| `resumeVerification(...)` | Resume an existing verification |
| `reset()` | Reset SDK configuration |
| `isConfigured` | Whether the SDK is configured |
| `version` | SDK version string |

### KoraIDVProvider (Widget)

InheritedWidget that auto-configures the SDK and provides a `KoraIDVController` to descendants.

### KoraIDVController (ChangeNotifier)

| Property | Type | Description |
|----------|------|-------------|
| `verification` | `Verification?` | Latest result |
| `error` | `KoraException?` | Latest error |
| `isLoading` | `bool` | Flow in progress |
| `isCancelled` | `bool` | User cancelled |

| Method | Description |
|--------|-------------|
| `startVerification(...)` | Start flow |
| `resumeVerification(...)` | Resume flow |
| `reset()` | Clear state |

### VerificationFlow (Widget)

Headless widget that auto-starts verification on mount and fires callbacks.

## Configuration Options

```dart
KoraIDVConfiguration(
  apiKey: 'ck_live_...',         // Required
  tenantId: 'uuid',              // Required
  environment: KoraEnvironment.production,
  baseUrl: 'https://...',        // Custom endpoint
  documentTypes: [DocumentType.usDriversLicense],
  livenessMode: LivenessMode.active,
  theme: KoraTheme(primaryColor: '#0000FF'),
  timeout: 600,                  // seconds
  debugLogging: false,
)
```

## Error Handling

All errors are typed as `KoraException` with:
- `code` — `KoraErrorCode` enum (33 error codes)
- `message` — Human-readable message
- `recoverySuggestion` — Optional recovery hint
- `isRetryable` — Whether the error is transient

## License

MIT
