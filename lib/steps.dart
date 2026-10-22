// Where steps come from: today's total from Health Connect (what the phone already counts, no battery
// cost), and live steps during a walk from the phone's step sensor. A fake in tests.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

enum StepSource {
  /// Health Connect gives today's steps, also from walks without Nūr.
  connected,

  /// No Health Connect: only walks started in Nūr count.
  walksOnly,
}

abstract class Steps {
  /// Today's steps so far from Health Connect, or null when they can't be read.
  Future<int?> today();

  /// Whether the phone's step counter may be used (Android: "Physical activity"). Without it Nūr can't
  /// count at all.
  Future<bool> counterAllowed();

  /// Asks for the step counter; true if allowed. Refused for good: opens Nūr's settings instead.
  Future<bool> allowCounter();

  /// Asks for Health Connect steps (counts while Nūr is closed too); true if allowed.
  Future<bool> connect();

  /// Whether Health Connect steps can be read (without asking).
  Future<bool> connected();

  /// The phone's step counter as it counts: steps since the phone started (it keeps counting while
  /// Nūr is closed). Errors if there is no step sensor or no permission.
  Stream<int> live();
}

class PhoneSteps implements Steps {
  final _health = Health();
  var _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<int?> today() async {
    try {
      await _configure();
      if (!await connected()) return null;
      final now = DateTime.now();
      return await _health.getTotalStepsInInterval(DateTime(now.year, now.month, now.day), now);
    } catch (e) {
      debugPrint('Steps unavailable: $e');
      return null;
    }
  }

  @override
  Future<bool> connected() async {
    try {
      await _configure();
      return await _health.hasPermissions([HealthDataType.STEPS]) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> counterAllowed() async {
    try {
      return await Permission.activityRecognition.isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> allowCounter() async {
    try {
      final s = await Permission.activityRecognition.request();
      if (s.isPermanentlyDenied) await openAppSettings(); // Android won't ask again: the switch is there
      return s.isGranted;
    } catch (e) {
      debugPrint('Could not ask for the step counter: $e');
      return false;
    }
  }

  @override
  Future<bool> connect() async {
    try {
      await _configure();
      if (await _health.getHealthConnectSdkStatus() != HealthConnectSdkStatus.sdkAvailable) return false;
      await _health.requestAuthorization([HealthDataType.STEPS]);
      return await connected();
    } catch (e) {
      debugPrint('Could not connect steps: $e');
      return false;
    }
  }

  @override
  Stream<int> live() => Pedometer.stepCountStream.map((e) => e.steps);
}
