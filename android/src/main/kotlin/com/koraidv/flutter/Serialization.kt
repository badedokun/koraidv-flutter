package com.koraidv.flutter

import com.koraidv.sdk.ChallengeResult
import com.koraidv.sdk.DocumentVerification
import com.koraidv.sdk.FaceVerification
import com.koraidv.sdk.LivenessVerification
import com.koraidv.sdk.RiskSignal
import com.koraidv.sdk.Verification
import com.koraidv.sdk.VerificationScores
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * Serialization helpers for crossing the Flutter MethodChannel bridge.
 *
 * Converts native SDK models -> HashMap<String, Any?> that Flutter's
 * StandardMethodCodec can transmit to the Dart layer.
 *
 * Unlike the RN bridge which serializes to JSON strings, Flutter's
 * StandardMethodCodec natively supports Maps.
 *
 * Mirrors koraidv-react-native's Serialization.kt adapted for Flutter.
 */
object Serialization {

    private val iso8601Format: SimpleDateFormat
        get() = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }

    /**
     * Build a success result map containing the verification.
     */
    fun buildSuccessResult(verification: Verification): HashMap<String, Any?> {
        return hashMapOf(
            "type" to "success",
            "verification" to serializeVerification(verification)
        )
    }

    /**
     * Build a cancelled result map.
     */
    fun buildCancelledResult(): HashMap<String, Any?> {
        return hashMapOf("type" to "cancelled")
    }

    /**
     * Serialize a Verification to a HashMap.
     */
    fun serializeVerification(v: Verification): HashMap<String, Any?> {
        val map = hashMapOf<String, Any?>(
            "id" to v.id,
            "externalId" to v.externalId,
            "tenantId" to v.tenantId,
            "tier" to v.tier,
            "status" to v.status.value,
            "createdAt" to formatDate(v.createdAt),
            "updatedAt" to formatDate(v.updatedAt),
            "completedAt" to v.completedAt?.let { formatDate(it) },
            "riskScore" to v.riskScore,
        )

        val docVerification = v.documentVerification
        if (docVerification != null) {
            map["documentVerification"] = serializeDocumentVerification(docVerification)
        }
        val faceVerification = v.faceVerification
        if (faceVerification != null) {
            map["faceVerification"] = serializeFaceVerification(faceVerification)
        }
        val livenessVerification = v.livenessVerification
        if (livenessVerification != null) {
            map["livenessVerification"] = serializeLivenessVerification(livenessVerification)
        }
        val scores = v.scores
        if (scores != null) {
            map["scores"] = serializeScores(scores)
        }
        val riskSignals = v.riskSignals
        if (riskSignals != null) {
            map["riskSignals"] = riskSignals.map { serializeRiskSignal(it) }
        }
        return map
    }

    private fun serializeDocumentVerification(dv: DocumentVerification): HashMap<String, Any?> {
        return hashMapOf(
            "documentType" to dv.documentType,
            "documentNumber" to dv.documentNumber,
            "firstName" to dv.firstName,
            "lastName" to dv.lastName,
            "dateOfBirth" to dv.dateOfBirth,
            "expirationDate" to dv.expirationDate,
            "issuingCountry" to dv.issuingCountry,
            "mrzValid" to dv.mrzValid,
            "authenticityScore" to dv.authenticityScore,
            "extractedFields" to dv.extractedFields,
        )
    }

    private fun serializeFaceVerification(fv: FaceVerification): HashMap<String, Any?> {
        return hashMapOf(
            "matchScore" to fv.matchScore,
            "matchResult" to fv.matchResult,
            "confidence" to fv.confidence,
        )
    }

    private fun serializeLivenessVerification(lv: LivenessVerification): HashMap<String, Any?> {
        val map = hashMapOf<String, Any?>(
            "livenessScore" to lv.livenessScore,
            "isLive" to lv.isLive,
        )
        val challengeResults = lv.challengeResults
        if (challengeResults != null) {
            map["challengeResults"] = challengeResults.map { serializeChallengeResult(it) }
        }
        return map
    }

    private fun serializeChallengeResult(cr: ChallengeResult): HashMap<String, Any?> {
        return hashMapOf(
            "type" to cr.type,
            "passed" to cr.passed,
            "confidence" to cr.confidence,
        )
    }

    private fun serializeScores(s: VerificationScores): HashMap<String, Any?> {
        return hashMapOf(
            "documentQuality" to s.documentQuality,
            "documentAuth" to s.documentAuth,
            "faceMatch" to s.faceMatch,
            "liveness" to s.liveness,
            "nameMatch" to s.nameMatch,
            "dataConsistency" to s.dataConsistency,
            "screening" to s.screening,
            "overall" to s.overall,
        )
    }

    private fun serializeRiskSignal(rs: RiskSignal): HashMap<String, Any?> {
        return hashMapOf(
            "code" to rs.code,
            "severity" to rs.severity,
            "message" to rs.message,
        )
    }

    private fun formatDate(date: Date): String {
        return iso8601Format.format(date)
    }
}
