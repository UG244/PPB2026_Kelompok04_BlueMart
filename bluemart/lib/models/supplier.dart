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
      name: 'ITB STIKOM Bali Renon',
      latitude: -8.6793,
      longitude: 115.2172,
      address: 'Jl. Raya Puputan No.86, Renon, Denpasar, Bali 80226',
    ),
    Supplier(
      name: 'Kampus ITB STIKOM (Kampus Baru)',
      latitude: -8.6771,
      longitude: 115.2160,
      address: 'Jl. Raya Puputan No.88, Renon, Denpasar, Bali 80226',
    ),
    Supplier(
      name: 'Toko Komputer Renon',
      latitude: -8.6812,
      longitude: 115.2195,
      address: 'Jl. Tukad Banyusari No.15, Renon, Denpasar',
    ),
    Supplier(
      name: 'Grosir Elektronik Denpasar',
      latitude: -8.6600,
      longitude: 115.2150,
      address: 'Jl. Diponegoro No.172, Denpasar Timur',
    ),
    Supplier(
      name: 'Distributor Gadget Bali',
      latitude: -8.6900,
      longitude: 115.2200,
      address: 'Jl. Teuku Umar No.25, Denpasar Barat',
    ),
  ];
}
