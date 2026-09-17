import 'dart:async';
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
/// Overpass API). Deliberately not Google Maps/Places — Overpass needs
/// no API key or billing account.
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

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw LocationException(
        "Couldn't get your location — try somewhere with a clearer view of the sky.",
      );
    }
  }

  // Order matters: overpass-api.de currently rejects requests with a
  // generic User-Agent/Accept header (HTTP 406), so it's kept last as a
  // fallback rather than dropped, while the two independently-run
  // mirrors are tried first.
  static const _overpassUrls = [
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass-api.de/api/interpreter',
  ];

  static const _requestHeaders = {
    'User-Agent': 'CineQuest/1.0 (Flutter movie-tracking app, student project)',
    'Accept': 'application/json, application/osm3s+xml, */*',
  };

  /// Queries OSM's tagged data for amenity=cinema nodes within
  /// [radiusMeters] of the given point.
  Future<List<CinemaLocation>> fetchNearbyCinemas({
    required double latitude,
    required double longitude,
    int radiusMeters = 10000,
  }) async {
    final query =
        '[out:json][timeout:25];node["amenity"="cinema"](around:$radiusMeters,$latitude,$longitude);out body;';

    // Mirrors are tried sequentially, capping worst case at 3x this
    // timeout (~30s) if every mirror fails. errors collects every
    // mirror's failure, tagged by host, so a report is diagnosable.
    final errors = <String>[];
    for (final url in _overpassUrls) {
      final host = Uri.parse(url).host;
      try {
        final response = await _client
            .post(Uri.parse(url), headers: _requestHeaders, body: {'data': query})
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final elements = decoded['elements'] as List? ?? [];
          return elements
              .map((e) => CinemaLocation.fromOverpassJson(e as Map<String, dynamic>))
              .toList();
        }
        errors.add('$host: HTTP ${response.statusCode}');
      } catch (e) {
        errors.add('$host: $e');
      }
    }

    throw LocationException(
      'Could not reach the cinema search service right now — the free '
      'service may be temporarily busy. Try again in a moment.\n(${errors.join(' | ')})',
    );
  }
}
