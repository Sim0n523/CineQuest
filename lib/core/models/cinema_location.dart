class CinemaLocation {
  final String id; // OSM node id
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  const CinemaLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory CinemaLocation.fromOverpassJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    return CinemaLocation(
      id: '${json['id']}',
      name: tags['name'] as String? ?? 'Unnamed Cinema',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      address: _buildAddress(tags),
    );
  }

  static String? _buildAddress(Map<String, dynamic> tags) {
    final parts = [
      tags['addr:housenumber'],
      tags['addr:street'],
      tags['addr:city'],
    ].whereType<String>().where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' ');
  }
}
