package com.example.fyp

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.view.WindowManager
import android.os.PowerManager


class CopyMainActivity : FlutterActivity() {
    private val CHANNEL = "lock_screen_channel"

    

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "lockScreen" -> {
                    lockScreen()
                    result.success("Locked")
                }
                "wakeScreen" -> {
                    wakeScreen()
                    result.success("Screen Woken")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun lockScreen() {
        val policyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val admin = ComponentName(this, MyDeviceAdminReceiver::class.java)
        if (policyManager.isAdminActive(admin)) {
            policyManager.lockNow()
        } else {
            // Device Admin not enabled — handle this properly in production
        }
    }

    private fun wakeScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            // From Android 8.1 (API 27) onwards
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "fyp:WakeLockTag"
        )
        wakeLock.acquire(3000) // Keep CPU awake for 3 seconds (screen will wake because of flags)
        wakeLock.release()
    }
}
