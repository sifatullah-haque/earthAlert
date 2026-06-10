import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum EarthquakeSeverity { critical, major, moderate, minor }

class EarthquakeModel {
  final String id;
  final String location;
  final String region;
  final String country;
  final double magnitude;
  final double depth;
  final double latitude;
  final double longitude;
  final DateTime time;
  final double radiusKm;
  final int casualties;
  final int affected;
  final bool isActive;

  const EarthquakeModel({
    required this.id,
    required this.location,
    required this.region,
    required this.country,
    required this.magnitude,
    required this.depth,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.radiusKm,
    this.casualties = 0,
    this.affected = 0,
    this.isActive = true,
  });

  EarthquakeSeverity get severity {
    if (magnitude >= 7.0) return EarthquakeSeverity.critical;
    if (magnitude >= 5.5) return EarthquakeSeverity.major;
    if (magnitude >= 4.0) return EarthquakeSeverity.moderate;
    return EarthquakeSeverity.minor;
  }

  Color get severityColor {
    switch (severity) {
      case EarthquakeSeverity.critical:
        return AppColors.magnitudeCritical;
      case EarthquakeSeverity.major:
        return AppColors.magnitudeMajor;
      case EarthquakeSeverity.moderate:
        return AppColors.magnitudeModerate;
      case EarthquakeSeverity.minor:
        return AppColors.magnitudeMinor;
    }
  }

  String get severityLabel {
    switch (severity) {
      case EarthquakeSeverity.critical:
        return 'CRITICAL';
      case EarthquakeSeverity.major:
        return 'MAJOR';
      case EarthquakeSeverity.moderate:
        return 'MODERATE';
      case EarthquakeSeverity.minor:
        return 'MINOR';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
