import Flutter
import UIKit
import KoraIDV

/// Flutter plugin for KoraIDV iOS SDK.
///
/// Exposes three MethodChannel calls:
///   - configure(config Map)
///   - startVerification(args Map) -> result Map
///   - resumeVerification(args Map) -> result Map
///
/// Results cross the bridge as [String: Any] dictionaries via
/// Flutter's StandardMethodCodec (no JSON string encoding needed).
///
/// Mirrors the RN bridge (KoraIDVReactNative.swift) adapted for Flutter.
public class KoraIDVFlutterPlugin: NSObject, FlutterPlugin {

    // MARK: - Plugin registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.koraidv.flutter/koraidv",
            binaryMessenger: registrar.messenger()
        )
        let instance = KoraIDVFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Method call handler

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            handleConfigure(call, result: result)
        case "startVerification":
            handleStartVerification(call, result: result)
        case "resumeVerification":
            handleResumeVerification(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - configure

    private func handleConfigure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String,
              let tenantId = args["tenantId"] as? String
        else {
            result(FlutterError(code: "INVALID_API_KEY", message: "Missing apiKey or tenantId.", details: nil))
            return
        }

        var config = Configuration(apiKey: apiKey, tenantId: tenantId)

        if let env = args["environment"] as? String {
            config.environment = env == "sandbox" ? .sandbox : .production
        }

        if let baseUrl = args["baseUrl"] as? String, let url = URL(string: baseUrl) {
            config.baseURL = url
        }

        if let docTypes = args["documentTypes"] as? [String] {
            config.documentTypes = docTypes.compactMap { DocumentType(rawValue: $0) }
        }

        if let liveness = args["livenessMode"] as? String {
            config.livenessMode = liveness == "passive" ? .passive : .active
        }

        if let themeMap = args["theme"] as? [String: Any] {
            var theme = KoraTheme()
            if let primary = themeMap["primaryColor"] as? String {
                theme.primaryColor = UIColor(hexString: primary)
            }
            if let bg = themeMap["backgroundColor"] as? String {
                theme.backgroundColor = UIColor(hexString: bg)
            }
            if let surface = themeMap["surfaceColor"] as? String {
                theme.surfaceColor = UIColor(hexString: surface)
            }
            if let text = themeMap["textColor"] as? String {
                theme.textColor = UIColor(hexString: text)
            }
            if let error = themeMap["errorColor"] as? String {
                theme.errorColor = UIColor(hexString: error)
            }
            if let success = themeMap["successColor"] as? String {
                theme.successColor = UIColor(hexString: success)
            }
            if let radius = themeMap["cornerRadius"] as? CGFloat {
                theme.cornerRadius = radius
            }
            config.theme = theme
        }

        if let timeout = args["timeout"] as? TimeInterval {
            config.timeout = timeout
        }

        if let debug = args["debugLogging"] as? Bool {
            config.debugLogging = debug
        }

        KoraIDV.configure(with: config)
        result(nil)
    }

    // MARK: - startVerification

    private func handleStartVerification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let externalId = args["externalId"] as? String,
              let tierString = args["tier"] as? String
        else {
            result(FlutterError(code: "VALIDATION_ERROR", message: "Missing externalId or tier.", details: nil))
            return
        }

        let tier: VerificationTier
        switch tierString {
        case "basic": tier = .basic
        case "enhanced": tier = .enhanced
        default: tier = .standard
        }

        DispatchQueue.main.async {
            guard let presenter = Self.topViewController() else {
                result(FlutterError(code: "NOT_CONFIGURED", message: "No presenting view controller found.", details: nil))
                return
            }

            KoraIDV.startVerification(
                externalId: externalId,
                tier: tier,
                from: presenter
            ) { verificationResult in
                Self.handleVerificationResult(verificationResult, result: result)
            }
        }
    }

    // MARK: - resumeVerification

    private func handleResumeVerification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let verificationId = args["verificationId"] as? String
        else {
            result(FlutterError(code: "VALIDATION_ERROR", message: "Missing verificationId.", details: nil))
            return
        }

        DispatchQueue.main.async {
            guard let presenter = Self.topViewController() else {
                result(FlutterError(code: "NOT_CONFIGURED", message: "No presenting view controller found.", details: nil))
                return
            }

            KoraIDV.resumeVerification(
                verificationId: verificationId,
                from: presenter
            ) { verificationResult in
                Self.handleVerificationResult(verificationResult, result: result)
            }
        }
    }

    // MARK: - Result handling

    private static func handleVerificationResult(
        _ verificationResult: VerificationResult,
        result: @escaping FlutterResult
    ) {
        switch verificationResult {
        case .success(let verification):
            result(FlutterSerialization.buildSuccessResult(verification))

        case .failure(let error):
            result(FlutterError(code: error.errorCode, message: error.message, details: nil))

        case .cancelled:
            result(FlutterSerialization.buildCancelledResult())
        }
    }

    // MARK: - Top view controller

    private static func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.delegate?.window ?? nil,
              var vc = window.rootViewController
        else {
            return nil
        }
        while let presented = vc.presentedViewController {
            vc = presented
        }
        return vc
    }
}

// MARK: - UIColor hex helper

private extension UIColor {
    convenience init(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
