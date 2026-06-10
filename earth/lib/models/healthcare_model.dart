import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum FacilityType { hospital, clinic, pharmacy, bloodBank }

class HealthcareModel {
  final String id;
  final String name;
  final FacilityType type;
  final double distanceKm;
  final String address;
  final bool isOpen;
  final String phone;
  final int availableBeds;
  final int totalBeds;
  final double rating;
  final List<String> specialties;
  final bool hasEmergency;
  final String operatingHours;

  const HealthcareModel({
    required this.id,
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.address,
    required this.isOpen,
    required this.phone,
    this.availableBeds = 0,
    this.totalBeds = 0,
    this.rating = 0,
    this.specialties = const [],
    this.hasEmergency = false,
    required this.operatingHours,
  });

  String get typeLabel {
    switch (type) {
      case FacilityType.hospital:
        return 'Hospital';
      case FacilityType.clinic:
        return 'Clinic';
      case FacilityType.pharmacy:
        return 'Pharmacy';
      case FacilityType.bloodBank:
        return 'Blood Bank';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case FacilityType.hospital:
        return Icons.local_hospital_rounded;
      case FacilityType.clinic:
        return Icons.medical_services_rounded;
      case FacilityType.pharmacy:
        return Icons.local_pharmacy_rounded;
      case FacilityType.bloodBank:
        return Icons.bloodtype_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case FacilityType.hospital:
        return AppColors.primary;
      case FacilityType.clinic:
        return AppColors.info;
      case FacilityType.pharmacy:
        return AppColors.accentGreen;
      case FacilityType.bloodBank:
        return AppColors.secondary;
    }
  }

  double get capacityPercentage =>
      totalBeds > 0 ? (availableBeds / totalBeds) : 0;

  Color get capacityColor {
    if (capacityPercentage > 0.5) return AppColors.success;
    if (capacityPercentage > 0.2) return AppColors.warning;
    return AppColors.primary;
  }
}
