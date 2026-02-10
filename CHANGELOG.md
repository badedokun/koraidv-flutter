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
