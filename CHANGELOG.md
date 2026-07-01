## 1.10.3

- Lockstep release. Durable server-side eyewear (sunglasses) enforcement:
  the on-device eye-visibility heuristic no longer hard-blocks selfie
  capture — a pretrained, face-independent sunglasses classifier in the
  KoraIDV backend is now the authoritative gate (opaque sunglasses are
  auto-rejected; ambiguous mirrored/tinted lenses route to manual review;
  bare eyes are never false-rejected). No Dart API changes. Refreshes the
  bundled Android AAR and the iOS pod to 1.10.3.

## 1.8.5

- Plug `showVisualGuides` through the Flutter bridge (Dart → Kotlin and
  Dart → Swift). Pre-1.8.5 the flag was silently dropped at the bridge
  layer on both platforms — `KoraIDVFlutterPlugin.kt` constructed
  `Configuration(...)` without `showVisualGuides`, and the iOS
  `handleConfigure` had no parsing for it. Every Flutter consumer
  rendered without Visual Guides regardless of what they set from Dart.
  Now plumbed end-to-end; Flutter wrapper defaults to `true` (matching
  Web SDK behavior). Set `showVisualGuides: false` on
  `KoraIDVConfiguration` to opt out.
- Catches up to RN/Web cross-platform parity (RN bridge fix shipped
  2026-05-25; Web SDK has defaulted true since 1.7.x).

## 1.8.4

- Lockstep with iOS / Android / RN / Web v1.8.4.
- iOS podspec deployment target corrected from 14.0 to 15.0 (required by
  SwiftUI Canvas / GraphicsContext APIs added in koraidv-ios v1.7.0 for
  Visual Guides). Same fix applies to the underlying KoraIDV pod dependency.
- iOS podspec version label corrected from stale 1.2.0 to 1.8.4 to match
  pubspec.yaml — caught while preparing the first pub.dev publish.

## 1.2.0

- Sync all SDK versions to v1.2.0 across Android, iOS, Flutter, React Native, and Web.
- Update native Android AAR to latest build with improved face match and reduced false rejections.
- Bump iOS podspec dependency version.

## 1.1.0

- Improved face match accuracy and reduced false rejections.
- Updated native Android AAR bundle.

## 1.0.0

- Initial release of the Kora IDV Flutter SDK.
- Thin MethodChannel wrapper over native iOS and Android KoraIDV SDKs.
- Imperative API: `KoraIDV.instance.configure()`, `startVerification()`, `resumeVerification()`, `reset()`.
- Widget API: `KoraIDVProvider`, `KoraIDVController`, `VerificationFlow`.
- Full type system: 12 document types, 9 verification statuses, 33 error codes.
- Sealed `VerificationFlowResult` (`VerificationSuccess` | `VerificationCancelled`).
- Typed `KoraException` with error codes, recovery suggestions, and `isRetryable`.
- iOS plugin: FlutterPlugin with MethodChannel, topmost ViewController presentation.
- Android plugin: FlutterPlugin + ActivityAware, startActivityForResult pattern.
- Unit tests for serialization, imperative API, and controller state machine.
- Example app demonstrating all three integration patterns.
