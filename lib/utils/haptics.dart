import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class Haptics {
  Haptics._();

  static Future<void> _vibrate(int duration, {int? amplitude}) async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: duration, amplitude: amplitude ?? 64);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> light() async {
    await _vibrate(10, amplitude: 32);
  }

  static Future<void> medium() async {
    await _vibrate(20, amplitude: 96);
  }

  static Future<void> heavy() async {
    await _vibrate(30, amplitude: 192);
  }

  static Future<void> selection() async {
    await _vibrate(5, amplitude: 24);
  }

  static Future<void> success() async {
    await _vibrate(15, amplitude: 80);
    await Future.delayed(const Duration(milliseconds: 80));
    await _vibrate(10, amplitude: 48);
  }

  static Future<void> error() async {
    await _vibrate(40, amplitude: 255);
  }

  static Future<void> toggle() async {
    await _vibrate(8, amplitude: 32);
  }
}
