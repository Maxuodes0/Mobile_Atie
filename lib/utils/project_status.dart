import 'package:flutter/material.dart';

String projectStatusLabel(String status, {String languageCode = 'ar'}) {
  final isArabic = languageCode == 'ar';
  switch (status) {
    case 'ON_TRACK':
      return isArabic ? 'على المسار' : 'On track';
    case 'AT_RISK':
      return isArabic ? 'معرّض للخطر' : 'At risk';
    case 'OFF_TRACK':
      return isArabic ? 'متأخر' : 'Off track';
    case 'COMPLETED':
      return isArabic ? 'مكتمل' : 'Completed';
    default:
      return status;
  }
}

Color projectStatusColor(String status) {
  switch (status) {
    case 'ON_TRACK':
      return const Color(0xFF4F9E8D);
    case 'AT_RISK':
      return const Color(0xFFF59E0B);
    case 'COMPLETED':
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFFEF4444);
  }
}
