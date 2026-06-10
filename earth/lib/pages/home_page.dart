import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../models/dummy_data.dart';
import '../models/earthquake_model.dart';

enum _LocationStatus { loading, success, denied, error }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _LocationStatus _locStatus = _LocationStatus.loading;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locStatus = _LocationStatus.loading);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _locStatus = _LocationStatus.denied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _position = pos;
        _locStatus = _LocationStatus.success;
      });
    } catch (_) {
      setState(() => _locStatus = _LocationStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = DummyData.latestEarthquake;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildAlertBanner(latest)),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildLocationCard()),
          SliverToBoxAdapter(child: _buildSectionHeader('Latest Earthquake')),
          SliverToBoxAdapter(child: _buildLatestEarthquakeCard(latest)),
          SliverToBoxAdapter(child: _buildSectionHeader('Recent Activity')),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildEarthquakeListItem(DummyData.earthquakes[index]),
              childCount: DummyData.earthquakes.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.radar, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Text(
            'EarthAlert',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_rounded,
                  color: AppColors.textPrimary, size: 24.sp),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildAlertBanner(EarthquakeModel eq) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.primaryDark.withValues(alpha: 0.95),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE EARTHQUAKE ALERT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'M${eq.magnitude} — ${eq.location}, ${eq.country}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              eq.timeAgo,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Active',
            value: '${DummyData.activeCount}',
            unit: 'quakes',
            icon: Icons.bolt_rounded,
            color: AppColors.primary,
          ),
          SizedBox(width: 10.w),
          _StatCard(
            label: 'Affected',
            value: _fmt(DummyData.totalAffected),
            unit: 'people',
            icon: Icons.people_rounded,
            color: AppColors.secondary,
          ),
          SizedBox(width: 10.w),
          _StatCard(
            label: 'Help Needed',
            value: '${DummyData.pendingHelp}',
            unit: 'requests',
            icon: Icons.volunteer_activism_rounded,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: _locStatus == _LocationStatus.loading
                  ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : Icon(
                      _locStatus == _LocationStatus.success
                          ? Icons.my_location_rounded
                          : Icons.location_off_rounded,
                      color: _locStatus == _LocationStatus.success
                          ? AppColors.accent
                          : AppColors.textHint,
                      size: 22.sp,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Location',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ..._locationContent(),
                ],
              ),
            ),
            GestureDetector(
              onTap: _fetchLocation,
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _locationContent() {
    switch (_locStatus) {
      case _LocationStatus.loading:
        return [
          Text(
            'Fetching location…',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13.sp,
            ),
          ),
        ];
      case _LocationStatus.success:
        final lat = _position!.latitude;
        final lng = _position!.longitude;
        final acc = _position!.accuracy.toStringAsFixed(0);
        return [
          Text(
            '${lat.toStringAsFixed(4)}°${lat >= 0 ? 'N' : 'S'}  '
            '${lng.toStringAsFixed(4)}°${lng >= 0 ? 'E' : 'W'}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Accuracy ±${acc}m',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11.sp,
            ),
          ),
        ];
      case _LocationStatus.denied:
        return [
          Text(
            'Location permission denied',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () => Geolocator.openAppSettings(),
            child: Text(
              'Open settings →',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];
      case _LocationStatus.error:
        return [
          Text(
            'Location unavailable',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13.sp,
            ),
          ),
        ];
    }
  }

  Widget _buildLatestEarthquakeCard(EarthquakeModel eq) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: eq.severityColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _MagnitudeCircle(
                    magnitude: eq.magnitude, color: eq.severityColor),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              eq.location,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: eq.severityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              eq.severityLabel,
                              style: TextStyle(
                                color: eq.severityColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        eq.region,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.vertical_align_bottom_rounded,
                            label: '${eq.depth} km depth',
                          ),
                          SizedBox(width: 8.w),
                          _InfoChip(
                            icon: Icons.radio_button_checked_rounded,
                            label: '${eq.radiusKm.toInt()} km radius',
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.people_rounded,
                            label: '${_fmt(eq.affected)} affected',
                          ),
                          SizedBox(width: 8.w),
                          if (eq.casualties > 0)
                            _InfoChip(
                              icon: Icons.emergency_rounded,
                              label: '${eq.casualties} casualties',
                              isAlert: true,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 10.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildEarthquakeListItem(EarthquakeModel eq) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: eq.severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                'M${eq.magnitude}',
                style: TextStyle(
                  color: eq.severityColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eq.location,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  eq.region,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                eq.timeAgo,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color:
                      eq.isActive ? AppColors.primary : AppColors.textHint,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MagnitudeCircle extends StatelessWidget {
  final double magnitude;
  final Color color;

  const _MagnitudeCircle({required this.magnitude, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              magnitude.toString(),
              style: TextStyle(
                color: color,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'MAG',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAlert;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? AppColors.primary : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12.sp),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: isAlert ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
