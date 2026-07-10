import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription? _subscription;
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

  /// Calculate relative angle from device heading to target bearing.
  /// Returns a value in degrees that can be used for Transform.rotate.
  static double calculateRelativeAngle(double deviceHeading, double targetBearing) {
    return (targetBearing - deviceHeading + 360) % 360;
  }

  void dispose() {
    _subscription?.cancel();
  }
}