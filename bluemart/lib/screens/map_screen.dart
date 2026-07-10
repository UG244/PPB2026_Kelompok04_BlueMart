import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/supplier.dart';
import '../services/location_service.dart';
import '../widgets/compass_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _isFollowingUser = true;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoading = true);
    final position = await _locationService.getCurrentLocation();

    if (mounted) {
      if (position != null) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
          _permissionDenied = false;
        });
        // Start listening to real-time location updates
        _startLocationUpdates();
      } else {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });
      }
    }
  }

  void _startLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        if (_isFollowingUser) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0,
          );
        }
      }
    });
  }

  void _recenterMap() {
    if (_userLocation != null) {
      setState(() => _isFollowingUser = true);
      _mapController.move(_userLocation!, 15.0);
    }
  }

  void _showSupplierInfo(Supplier supplier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              supplier.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    supplier.address,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            if (_userLocation != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${(_locationService.calculateDistance(_userLocation!.latitude, _userLocation!.longitude, supplier.latitude, supplier.longitude) / 1000).toStringAsFixed(1)} km dari lokasi Anda',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions, size: 18),
                onPressed: () => Navigator.pop(context),
                label: const Text('Navigasi ke Supplier'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta & Supplier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _recenterMap,
            tooltip: 'Recenter ke lokasi saya',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_userLocation != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation!,
                initialZoom: 15.0,
                onTap: (_, tapPosition) {},
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.bluemart',
                ),
                // User marker with live GPS position
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                    ),
                    // Supplier markers
                    ...Supplier.sampleSuppliers.map(
                      (supplier) => Marker(
                        point: LatLng(supplier.latitude, supplier.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _showSupplierInfo(supplier),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            const Center(child: Text('Tidak dapat memuat peta')),

          // Permission denied message
          if (_permissionDenied)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi tidak diizinkan. Aktifkan GPS untuk melihat lokasi real-time.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Not following indicator
          if (!_isFollowingUser && _userLocation != null)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _recenterMap,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),

          // Compass widget
          if (_userLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: CompassWidget(
                userLatitude: _userLocation!.latitude,
                userLongitude: _userLocation!.longitude,
              ),
            ),
        ],
      ),
    );
  }
}