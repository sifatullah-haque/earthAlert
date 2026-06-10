import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../models/dummy_data.dart';
import '../models/earthquake_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  EarthquakeModel? _selectedEq;
  bool _showLegend = false;

  static const _defaultCenter = LatLng(23.6850, 90.3563);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          if (_showLegend) _buildLegend(),
          if (_selectedEq != null) _buildBottomSheet(_selectedEq!),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 7.0,
        onTap: (_, __) => setState(() => _selectedEq = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.earth',
          tileBuilder: _darkTileBuilder,
        ),
        CircleLayer(
          circles: DummyData.earthquakes.map((eq) {
            return CircleMarker(
              point: LatLng(eq.latitude, eq.longitude),
              radius: eq.radiusKm * 1000,
              useRadiusInMeter: true,
              color: eq.severityColor.withValues(alpha: 0.12),
              borderColor: eq.severityColor.withValues(alpha: 0.6),
              borderStrokeWidth: 1.5,
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: DummyData.earthquakes.map((eq) {
            final isSelected = _selectedEq?.id == eq.id;
            return Marker(
              point: LatLng(eq.latitude, eq.longitude),
              width: isSelected ? 56 : 44,
              height: isSelected ? 56 : 44,
              child: GestureDetector(
                onTap: () => setState(() => _selectedEq = eq),
                child: _EarthquakeMarker(
                  earthquake: eq,
                  isSelected: isSelected,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _darkTileBuilder(
      BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withValues(alpha: 0.95),
              AppColors.background.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 14),
                        Icon(Icons.search_rounded,
                            color: AppColors.textHint, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search location...',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _showLegend = !_showLegend),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _showLegend ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Icon(
                      Icons.layers_rounded,
                      color: _showLegend
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 90,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MAGNITUDE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            _LegendItem(color: AppColors.magnitudeCritical, label: '≥ 7.0 Critical'),
            _LegendItem(color: AppColors.magnitudeMajor, label: '5.5–6.9 Major'),
            _LegendItem(color: AppColors.magnitudeModerate, label: '4.0–5.4 Moderate'),
            _LegendItem(color: AppColors.magnitudeMinor, label: '< 4.0 Minor'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(EarthquakeModel eq) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: eq.severityColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: eq.severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    eq.severityLabel,
                    style: TextStyle(
                      color: eq.severityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _selectedEq = null),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: eq.severityColor.withValues(alpha: 0.1),
                    border: Border.all(
                        color: eq.severityColor.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'M${eq.magnitude}',
                      style: TextStyle(
                        color: eq.severityColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eq.location,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        eq.region,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _DetailTile(label: 'Depth', value: '${eq.depth} km'),
                _DetailTile(label: 'Radius', value: '${eq.radiusKm} km'),
                _DetailTile(label: 'Affected', value: '${eq.affected}'),
                _DetailTile(label: 'Time', value: eq.timeAgo),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _mapController.move(
                  LatLng(eq.latitude, eq.longitude),
                  10,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: eq.severityColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text(
                  'Focus Epicenter',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarthquakeMarker extends StatelessWidget {
  final EarthquakeModel earthquake;
  final bool isSelected;

  const _EarthquakeMarker(
      {required this.earthquake, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earthquake.severityColor,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: earthquake.severityColor.withValues(alpha: 0.5),
            blurRadius: isSelected ? 16 : 8,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${earthquake.magnitude}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
