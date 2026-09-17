import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/models/cinema_location.dart';
import '../core/services/location_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/empty_state.dart';

/// Nearby cinemas via device GPS + OpenStreetMap's free Overpass API —
/// no Google Maps API key or billing account needed.
///
/// Two modes:
/// - Browsing (selectionMode: false, default) — reachable from Profile,
///   tapping a cinema just centers the map on it.
/// - Selecting (selectionMode: true) — reachable from Log Movie's
///   "find nearby" button, tapping a cinema pops this screen and
///   returns its name to pre-fill the Cinema field.
class NearbyCinemasScreen extends StatefulWidget {
  final bool selectionMode;

  const NearbyCinemasScreen({super.key, this.selectionMode = false});

  @override
  State<NearbyCinemasScreen> createState() => _NearbyCinemasScreenState();
}

class _NearbyCinemasScreenState extends State<NearbyCinemasScreen> {
  final _locationService = LocationService();
  final _mapController = MapController();

  bool _loading = true;
  String? _error;
  LatLng? _userLocation;
  List<CinemaLocation> _cinemas = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      final userLatLng = LatLng(position.latitude, position.longitude);
      final cinemas = await _locationService.fetchNearbyCinemas(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _userLocation = userLatLng;
        _cinemas = cinemas;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _handleTap(CinemaLocation cinema) {
    if (widget.selectionMode) {
      Navigator.of(context).pop(cinema.name);
    } else {
      _mapController.move(LatLng(cinema.latitude, cinema.longitude), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nearby Cinemas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded, color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(_error!, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Try Again', onPressed: _load),
            ],
          ),
        ),
      );
    }

    final userLocation = _userLocation!;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: userLocation, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cinequest',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location_rounded, color: AppColors.xp, size: 30),
                  ),
                  for (final cinema in _cinemas)
                    Marker(
                      point: LatLng(cinema.latitude, cinema.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _handleTap(cinema),
                        child: const Icon(
                          Icons.theaters_rounded,
                          color: AppColors.primaryAccent,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _cinemas.isEmpty
              ? const EmptyState(
                  icon: Icons.theaters_rounded,
                  title: 'No cinemas found nearby',
                  message: 'Try again in a more populated area, or check back later.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cinemas.length,
                  itemBuilder: (context, index) {
                    final cinema = _cinemas[index];
                    return ListTile(
                      leading: const Icon(Icons.theaters_rounded, color: AppColors.primaryAccent),
                      title: Text(cinema.name, style: AppTextStyles.body),
                      subtitle:
                          cinema.address != null ? Text(cinema.address!, style: AppTextStyles.caption) : null,
                      trailing: widget.selectionMode
                          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)
                          : null,
                      onTap: () => _handleTap(cinema),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
