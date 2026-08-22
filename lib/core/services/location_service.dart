import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/cinema_location.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

/// Wraps device GPS (geolocator) and nearby-cinema search (OpenStreetMap's
/// Overpass API). Deliberately not Google Maps/Places — see README for
/// why: Overpass needs no API key and no billing account at all, which
/// matters for a project where that's worth avoiding entirely.
class LocationService {
  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are turned off on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw LocationException('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Enable it in system settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  // A few known public Overpass mirrors — the free shared service
  // (particularly the main overpass-api.de instance) is occasionally
  // rate-limited or overloaded, so trying alternates before giving up
  // meaningfully improves reliability over hitting just one endpoint.
  static const _overpassUrls = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  /// Queries OSM's tagged data for amenity=cinema nodes within
  /// [radiusMeters] of the given point.
  Future<List<CinemaLocation>> fetchNearbyCinemas({
    required double latitude,
    required double longitude,
    int radiusMeters = 10000,
  }) async {
    final query =
        '[out:json][timeout:25];node["amenity"="cinema"](around:$radiusMeters,$latitude,$longitude);out body;';

    Object? lastError;
    for (final url in _overpassUrls) {
      try {
        final response = await _client
            .post(Uri.parse(url), body: {'data': query})
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final elements = decoded['elements'] as List? ?? [];
          return elements
              .map((e) => CinemaLocation.fromOverpassJson(e as Map<String, dynamic>))
              .toList();
        }
        lastError = 'HTTP ${response.statusCode}';
      } catch (e) {
        lastError = e;
      }
    }

    throw LocationException(
      'Could not reach the cinema search service right now — the free '
      'service may be temporarily busy. Try again in a moment. ($lastError)',
    );
  }
}
