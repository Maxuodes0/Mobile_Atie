import 'package:flutter/material.dart';

String projectStatusLabel(String status) {
  switch (status) {
    case 'ON_TRACK':
      return 'على المسار';
    case 'AT_RISK':
      return 'معرّض للخطر';
    case 'OFF_TRACK':
      return 'متأخر';
    case 'COMPLETED':
      return 'مكتمل';
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
