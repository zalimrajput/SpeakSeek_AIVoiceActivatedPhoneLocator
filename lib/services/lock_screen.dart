import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class LockService {
  // The MethodChannel must match the one in MainActivity.kt
  static const platform = MethodChannel('lock_screen_channel');

  /// Lock the screen (requires device admin permission)
  static Future<void> lockScreen() async {
    try {
      final result = await platform.invokeMethod('lockScreen');
      print('Lock screen result: $result');
    } on PlatformException catch (e) {
      print("Error locking screen: ${e.message}");
    }
  }

  /// Wake the screen (no unlock, just wake up)
  static Future<void> wakeScreen() async {
    try {
      final result = await platform.invokeMethod('wakeScreen');
      print('Wake screen result: $result');
    } on PlatformException catch (e) {
      print("Error waking screen: ${e.message}");
    }
  }

  /// Acquire a partial WakeLock (keep CPU on, screen stays off)
  static Future<void> acquireWakeLock() async {
    try {
      final result = await platform.invokeMethod('acquireWakeLock');
      print('Acquire WakeLock result: $result');
    } on PlatformException catch (e) {
      print("Error acquiring WakeLock: ${e.message}");
    }
  }

  /// Release the WakeLock (allow CPU to sleep)
  static Future<void> releaseWakeLock() async {
    try {
      final result = await platform.invokeMethod('releaseWakeLock');
      print('Release WakeLock result: $result');
    } on PlatformException catch (e) {
      print("Error releasing WakeLock: ${e.message}");
    }
  }

  static void openDeviceAdminSettings() {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.app.action.ADD_DEVICE_ADMIN',
      arguments: <String, dynamic>{
        'android.app.extra.DEVICE_ADMIN':
            'com.example.fyp/.MyDeviceAdminReceiver',
      },
    );
    intent.launch();
  }
}
