package com.koraidv.flutter

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import com.koraidv.sdk.Configuration
import com.koraidv.sdk.DocumentType
import com.koraidv.sdk.KoraException
import com.koraidv.sdk.KoraIDV
import com.koraidv.sdk.KoraTheme
import com.koraidv.sdk.LivenessMode
import com.koraidv.sdk.Verification
import com.koraidv.sdk.VerificationRequest
import com.koraidv.sdk.VerificationTier
import com.koraidv.sdk.ui.VerificationActivity

/**
 * Flutter plugin for KoraIDV Android SDK.
 *
 * Implements [FlutterPlugin] + [ActivityAware] to get the current Activity
 * for launching the native verification UI via startActivityForResult.
 *
 * Exposes three MethodChannel calls:
 *   - configure(config Map)
 *   - startVerification(args Map) -> result Map
 *   - resumeVerification(args Map) -> result Map
 *
 * Mirrors koraidv-react-native's KoraIDVReactNativeModule.kt adapted
 * for Flutter's plugin architecture.
 */
class KoraIDVFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    companion object {
        private const val CHANNEL_NAME = "com.koraidv.flutter/koraidv"
        private const val REQUEST_CODE_VERIFICATION = 9002
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: MethodChannel.Result? = null

    // -----------------------------------------------------------------------
    // FlutterPlugin
    // -----------------------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // -----------------------------------------------------------------------
    // ActivityAware
    // -----------------------------------------------------------------------

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(this)
        activity = null
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activity = null
        activityBinding = null
    }

    // -----------------------------------------------------------------------
    // MethodCallHandler
    // -----------------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> handleConfigure(call, result)
            "startVerification" -> handleStartVerification(call, result)
            "resumeVerification" -> handleResumeVerification(call, result)
            else -> result.notImplemented()
        }
    }

    // -----------------------------------------------------------------------
    // configure
    // -----------------------------------------------------------------------

    private fun handleConfigure(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
        if (args == null) {
            result.error("VALIDATION_ERROR", "Missing configuration arguments.", null)
            return
        }

        val apiKey = args["apiKey"] as? String
        val tenantId = args["tenantId"] as? String
        if (apiKey == null || tenantId == null) {
            result.error("INVALID_API_KEY", "Missing apiKey or tenantId.", null)
            return
        }

        val documentTypes = (args["documentTypes"] as? List<*>)?.mapNotNull { code ->
            DocumentType.fromCode(code as? String ?: "")
        } ?: DocumentType.entries

        val livenessMode = if ((args["livenessMode"] as? String) == "passive") {
            LivenessMode.PASSIVE
        } else {
            LivenessMode.ACTIVE
        }

        val theme = (args["theme"] as? Map<*, *>)?.let { themeMap ->
            KoraTheme(
                primaryColor = (themeMap["primaryColor"] as? String)?.hexToLong()
                    ?: KoraTheme().primaryColor,
                backgroundColor = (themeMap["backgroundColor"] as? String)?.hexToLong()
                    ?: KoraTheme().backgroundColor,
                surfaceColor = (themeMap["surfaceColor"] as? String)?.hexToLong()
                    ?: KoraTheme().surfaceColor,
                textColor = (themeMap["textColor"] as? String)?.hexToLong()
                    ?: KoraTheme().textColor,
                errorColor = (themeMap["errorColor"] as? String)?.hexToLong()
                    ?: KoraTheme().errorColor,
                successColor = (themeMap["successColor"] as? String)?.hexToLong()
                    ?: KoraTheme().successColor,
                cornerRadius = (themeMap["cornerRadius"] as? Double)?.toFloat() ?: 12f
            )
        } ?: KoraTheme()

        val config = Configuration(
            apiKey = apiKey,
            tenantId = tenantId,
            baseUrl = (args["baseUrl"] as? String)?.ifEmpty { null },
            documentTypes = documentTypes,
            livenessMode = livenessMode,
            theme = theme,
            timeout = (args["timeout"] as? Number)?.toLong() ?: 600L,
            debugLogging = (args["debugLogging"] as? Boolean) ?: false
        )

        KoraIDV.configure(config)
        result.success(null)
    }

    // -----------------------------------------------------------------------
    // startVerification
    // -----------------------------------------------------------------------

    private fun handleStartVerification(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
        val externalId = args?.get("externalId") as? String
        val tierString = args?.get("tier") as? String

        if (externalId == null || tierString == null) {
            result.error("VALIDATION_ERROR", "Missing externalId or tier.", null)
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NOT_CONFIGURED", "No current activity found.", null)
            return
        }

        if (!KoraIDV.isConfigured) {
            result.error("NOT_CONFIGURED", "SDK not configured. Call KoraIDV.configure() first.", null)
            return
        }

        val tier = when (tierString) {
            "basic" -> VerificationTier.BASIC
            "enhanced" -> VerificationTier.ENHANCED
            else -> VerificationTier.STANDARD
        }

        val request = VerificationRequest(
            externalId = externalId,
            tier = tier
        )

        pendingResult = result

        val intent = VerificationActivity.createIntent(currentActivity, request)
        currentActivity.startActivityForResult(intent, REQUEST_CODE_VERIFICATION)
    }

    // -----------------------------------------------------------------------
    // resumeVerification
    // -----------------------------------------------------------------------

    private fun handleResumeVerification(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
        val verificationId = args?.get("verificationId") as? String

        if (verificationId == null) {
            result.error("VALIDATION_ERROR", "Missing verificationId.", null)
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NOT_CONFIGURED", "No current activity found.", null)
            return
        }

        if (!KoraIDV.isConfigured) {
            result.error("NOT_CONFIGURED", "SDK not configured. Call KoraIDV.configure() first.", null)
            return
        }

        pendingResult = result

        val intent = VerificationActivity.createResumeIntent(currentActivity, verificationId)
        currentActivity.startActivityForResult(intent, REQUEST_CODE_VERIFICATION)
    }

    // -----------------------------------------------------------------------
    // Activity result
    // -----------------------------------------------------------------------

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_VERIFICATION) return false

        val result = pendingResult ?: return false
        pendingResult = null

        when (resultCode) {
            Activity.RESULT_OK -> {
                @Suppress("DEPRECATION")
                val verification = data?.getParcelableExtra<Verification>(
                    VerificationActivity.EXTRA_VERIFICATION
                )
                if (verification != null) {
                    result.success(Serialization.buildSuccessResult(verification))
                } else {
                    result.error("UNKNOWN", "Missing verification data in result.", null)
                }
            }
            Activity.RESULT_CANCELED -> {
                @Suppress("DEPRECATION")
                val error = data?.getParcelableExtra<KoraException>(
                    VerificationActivity.EXTRA_ERROR
                )
                if (error != null) {
                    result.error(error.errorCode, error.message, null)
                } else {
                    result.success(Serialization.buildCancelledResult())
                }
            }
            else -> {
                result.success(Serialization.buildCancelledResult())
            }
        }

        return true
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private fun String.hexToLong(): Long? {
        if (this.isEmpty()) return null
        val hex = this.removePrefix("#")
        if (hex.length != 6) return null
        return try {
            (0xFF000000 or hex.toLong(16))
        } catch (_: NumberFormatException) {
            null
        }
    }
}
