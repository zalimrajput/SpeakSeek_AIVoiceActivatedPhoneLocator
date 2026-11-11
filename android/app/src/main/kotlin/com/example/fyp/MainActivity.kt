package com.example.fyp

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
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
                "acquireWakeLock" -> {
                    acquireWakeLock()
                    result.success("WakeLock Acquired")
                }
                "releaseWakeLock" -> {
                    releaseWakeLock()
                    result.success("WakeLock Released")
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
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "fyp:WakeLockTag"
        )
        wakeLock.acquire(3000) // wake for 3 seconds
        wakeLock.release()
    }


    private var wakeLock: PowerManager.WakeLock? = null

    private fun acquireWakeLock() {
        if (wakeLock == null) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK, // Only CPU stays awake, screen off (for background tasks)
                "fyp:PartialWakeLockTag"
            )
            wakeLock?.acquire()
        }
    }

    private fun releaseWakeLock() {
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
        wakeLock = null
    }

}
