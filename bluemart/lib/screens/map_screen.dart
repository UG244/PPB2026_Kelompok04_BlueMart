import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

  @override
  void initState() {
    super.initState();
    _getLocation();
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
      } else {
        // Fallback to ITB STIKOM Bali Renon
        setState(() {
          _userLocation = const LatLng(-8.6793, 115.2172);
          _isLoading = false;
          _permissionDenied = true;
        });
      }
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
              child: ElevatedButton(
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
            onPressed: _getLocation,
            tooltip: 'Recenter',
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
                initialZoom: 13.0,
                onTap: (_, tapPosition) {},
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.bluemart',
                ),
                // User marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 36,
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
                        'Lokasi tidak diizinkan. Menampilkan lokasi default.',
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
