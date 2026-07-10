class Supplier {
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  const Supplier({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  static const List<Supplier> sampleSuppliers = [
    Supplier(
      name: 'PT Sumber Makmur',
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Jl. Merdeka No. 10, Jakarta Pusat',
    ),
    Supplier(
      name: 'CV Berkah Jaya',
      latitude: -6.2176,
      longitude: 106.8223,
      address: 'Jl. Sudirman No. 45, Jakarta Selatan',
    ),
    Supplier(
      name: 'UD Segar Abadi',
      latitude: -6.1945,
      longitude: 106.8356,
      address: 'Jl. Thamrin No. 22, Jakarta Pusat',
    ),
    Supplier(
      name: 'Toko Grosir Indah',
      latitude: -6.2289,
      longitude: 106.8546,
      address: 'Jl. Matraman No. 78, Jakarta Timur',
    ),
    Supplier(
      name: 'Distributor Utama',
      latitude: -6.2185,
      longitude: 106.8712,
      address: 'Jl. Gunung Sahari No. 15, Jakarta Utara',
    ),
  ];
}