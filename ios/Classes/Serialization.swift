import Foundation
import KoraIDV

/// Helpers to convert native KoraIDV models to [String: Any] dictionaries
/// for passing across the Flutter MethodChannel.
///
/// Mirrors the RN bridge's handleResult serialization, but returns
/// dictionaries instead of JSON strings (Flutter's StandardMethodCodec
/// handles Map serialization natively).
enum FlutterSerialization {

    // MARK: - ISO 8601 formatter

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    // MARK: - Success result

    static func buildSuccessResult(_ verification: Verification) -> [String: Any] {
        return [
            "type": "success",
            "verification": serializeVerification(verification)
        ]
    }

    // MARK: - Cancelled result

    static func buildCancelledResult() -> [String: Any] {
        return ["type": "cancelled"]
    }

    // MARK: - Verification

    static func serializeVerification(_ v: Verification) -> [String: Any] {
        var map: [String: Any] = [
            "id": v.id,
            "externalId": v.externalId,
            "tenantId": v.tenantId,
            "tier": v.tier,
            "status": v.status.rawValue,
            "createdAt": iso8601.string(from: v.createdAt),
            "updatedAt": iso8601.string(from: v.updatedAt),
        ]

        if let dv = v.documentVerification {
            map["documentVerification"] = serializeDocumentVerification(dv)
        }
        if let fv = v.faceVerification {
            map["faceVerification"] = serializeFaceVerification(fv)
        }
        if let lv = v.livenessVerification {
            map["livenessVerification"] = serializeLivenessVerification(lv)
        }
        if let rs = v.riskSignals {
            map["riskSignals"] = rs.map { serializeRiskSignal($0) }
        }
        if let score = v.riskScore {
            map["riskScore"] = score
        }
        if let completed = v.completedAt {
            map["completedAt"] = iso8601.string(from: completed)
        }

        return map
    }

    // MARK: - Document Verification

    private static func serializeDocumentVerification(_ dv: DocumentVerification) -> [String: Any] {
        var map: [String: Any] = [
            "documentType": dv.documentType,
        ]
        if let v = dv.documentNumber { map["documentNumber"] = v }
        if let v = dv.firstName { map["firstName"] = v }
        if let v = dv.lastName { map["lastName"] = v }
        if let v = dv.dateOfBirth { map["dateOfBirth"] = v }
        if let v = dv.expirationDate { map["expirationDate"] = v }
        if let v = dv.issuingCountry { map["issuingCountry"] = v }
        if let v = dv.mrzValid { map["mrzValid"] = v }
        if let v = dv.authenticityScore { map["authenticityScore"] = v }
        if let v = dv.extractedFields { map["extractedFields"] = v }
        return map
    }

    // MARK: - Face Verification

    private static func serializeFaceVerification(_ fv: FaceVerification) -> [String: Any] {
        return [
            "matchScore": fv.matchScore,
            "matchResult": fv.matchResult,
            "confidence": fv.confidence,
        ]
    }

    // MARK: - Liveness Verification

    private static func serializeLivenessVerification(_ lv: LivenessVerification) -> [String: Any] {
        var map: [String: Any] = [
            "livenessScore": lv.livenessScore,
            "isLive": lv.isLive,
        ]
        if let cr = lv.challengeResults {
            map["challengeResults"] = cr.map { serializeChallengeResult($0) }
        }
        return map
    }

    // MARK: - Challenge Result

    private static func serializeChallengeResult(_ cr: ChallengeResult) -> [String: Any] {
        return [
            "type": cr.type,
            "passed": cr.passed,
            "confidence": cr.confidence,
        ]
    }

    // MARK: - Risk Signal

    private static func serializeRiskSignal(_ rs: RiskSignal) -> [String: Any] {
        return [
            "code": rs.code,
            "severity": rs.severity,
            "message": rs.message,
        ]
    }
}
