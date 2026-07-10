import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sensor_service.dart';
import '../services/location_service.dart';
import '../models/supplier.dart';

class CompassWidget extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;

  const CompassWidget({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  final SensorService _sensorService = SensorService();
  final LocationService _locationService = LocationService();
  StreamSubscription? _headingSubscription;
  double _currentHeading = 0;
  bool _sensorAvailable = true;
  Supplier? _nearestSupplier;
  double? _bearingToNearest;

  @override
  void initState() {
    super.initState();
    _findNearestSupplier();
    _startListening();
  }

  void _findNearestSupplier() {
    _nearestSupplier = _locationService.findNearestSupplier(
      widget.userLatitude,
      widget.userLongitude,
    );
    if (_nearestSupplier != null) {
      _bearingToNearest = _locationService.calculateBearing(
        widget.userLatitude,
        widget.userLongitude,
        _nearestSupplier!.latitude,
        _nearestSupplier!.longitude,
      );
    }
  }

  void _startListening() {
    _headingSubscription = _sensorService.getHeadingStream().listen(
      (heading) {
        if (mounted) {
          setState(() => _currentHeading = heading);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _sensorAvailable = false);
      },
    );
  }

  @override
  void dispose() {
    _headingSubscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compass arrow
          if (_sensorAvailable && _bearingToNearest != null)
            Transform.rotate(
              angle: (_bearingToNearest! - _currentHeading) * 3.14159265 / 180,
              child: const Icon(
                Icons.navigation,
                size: 32,
                color: Colors.red,
              ),
            )
          else
            const Icon(Icons.explore, size: 32, color: Colors.grey),

          const SizedBox(height: 8),

          // Supplier info
          if (_nearestSupplier != null) ...[
            Text(
              'Terdekat: ${_nearestSupplier!.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '${(_locationService.calculateDistance(
                widget.userLatitude,
                widget.userLongitude,
                _nearestSupplier!.latitude,
                _nearestSupplier!.longitude,
              ) / 1000).toStringAsFixed(1)} km',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ] else
            Text(
              'Tidak ada supplier terdekat',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),

          if (!_sensorAvailable)
            Text(
              'Sensor kompas tidak tersedia',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}