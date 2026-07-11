import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription? _subscription;
  StreamSubscription<UserAccelerometerEvent>? _shakeSubscription;
  StreamSubscription<AccelerometerEvent>? _rawShakeSubscription;
  DateTime? _lastShakeTime;
  double _currentHeading = 0;
  bool _isAvailable = true;

  double get currentHeading => _currentHeading;
  bool get isAvailable => _isAvailable;

  /// Start listening to magnetometer data.
  /// Returns a stream of heading values in degrees (0-360).
  Stream<double> getHeadingStream() {
    return magnetometerEventStream().map((event) {
      // Calculate heading from magnetometer x, y, z
      // For a device held flat (most common), use x and y
      final heading = (atan2(event.y, event.x) * 180 / 3.14159265 + 360) % 360;
      _currentHeading = heading;
      _isAvailable = true;
      return heading;
    }).handleError((error) {
      _isAvailable = false;
      return 0.0;
    });
  }

  /// Start listening to accelerometer for shake gestures (Shake to Refresh / Shake for New Product).
  /// Fires when acceleration exceeds threshold.
  /// Debounces rapid shakes using [cooldown] (default 1.5 seconds).
  Stream<void> getShakeStream({
    double userAccelThreshold = 13.0,
    double rawAccelThreshold = 20.0,
    Duration cooldown = const Duration(milliseconds: 1500),
  }) {
    final controller = StreamController<void>.broadcast();

    void checkShake(double accel, double threshold) {
      if (accel > threshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > cooldown) {
          _lastShakeTime = now;
          if (!controller.isClosed) {
            controller.add(null);
          }
        }
      }
    }

    try {
      _shakeSubscription = userAccelerometerEventStream().listen(
        (UserAccelerometerEvent event) {
          final double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          checkShake(acceleration, userAccelThreshold);
        },
        onError: (error) {},
      );
    } catch (e) {
      // Handle missing sensor gracefully
    }

    try {
      _rawShakeSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          checkShake(acceleration, rawAccelThreshold);
        },
        onError: (error) {},
      );
    } catch (e) {
      // Handle missing sensor gracefully
    }

    controller.onCancel = () {
      _shakeSubscription?.cancel();
      _rawShakeSubscription?.cancel();
    };

    return controller.stream;
  }

  /// Calculate relative angle from device heading to target bearing.
  /// Returns a value in degrees that can be used for Transform.rotate.
  static double calculateRelativeAngle(double deviceHeading, double targetBearing) {
    return (targetBearing - deviceHeading + 360) % 360;
  }

  void dispose() {
    _subscription?.cancel();
    _shakeSubscription?.cancel();
    _rawShakeSubscription?.cancel();
  }
}