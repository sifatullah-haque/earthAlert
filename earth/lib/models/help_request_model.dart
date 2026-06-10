import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum HelpType { medical, rescue, food, shelter, water, other }

enum HelpStatus { pending, accepted, resolved }

class HelpRequestModel {
  final String id;
  final String name;
  final String avatarInitials;
  final HelpType type;
  final String description;
  final double distanceKm;
  final String address;
  final bool isUrgent;
  final DateTime requestTime;
  final HelpStatus status;
  final int peopleCount;
  final String phone;

  const HelpRequestModel({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.type,
    required this.description,
    required this.distanceKm,
    required this.address,
    this.isUrgent = false,
    required this.requestTime,
    this.status = HelpStatus.pending,
    this.peopleCount = 1,
    required this.phone,
  });

  String get typeLabel {
    switch (type) {
      case HelpType.medical:
        return 'Medical';
      case HelpType.rescue:
        return 'Rescue';
      case HelpType.food:
        return 'Food';
      case HelpType.shelter:
        return 'Shelter';
      case HelpType.water:
        return 'Water';
      case HelpType.other:
        return 'Other';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case HelpType.medical:
        return Icons.medical_services_rounded;
      case HelpType.rescue:
        return Icons.emergency_rounded;
      case HelpType.food:
        return Icons.restaurant_rounded;
      case HelpType.shelter:
        return Icons.home_rounded;
      case HelpType.water:
        return Icons.water_drop_rounded;
      case HelpType.other:
        return Icons.help_outline_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case HelpType.medical:
        return AppColors.primary;
      case HelpType.rescue:
        return AppColors.secondary;
      case HelpType.food:
        return AppColors.warning;
      case HelpType.shelter:
        return AppColors.info;
      case HelpType.water:
        return AppColors.accent;
      case HelpType.other:
        return AppColors.textSecondary;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(requestTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
