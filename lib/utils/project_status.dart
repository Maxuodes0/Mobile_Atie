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
    case 'CANCELLED':
      return isArabic ? 'ملغي' : 'Cancelled';
    default:
      return status;
  }
}

Color projectStatusColor(String status) {
  switch (status) {
    case 'ON_TRACK':
      return const Color(0xFF6F8F83);
    case 'AT_RISK':
      return const Color(0xFF9A8468);
    case 'COMPLETED':
      return const Color(0xFF687887);
    case 'CANCELLED':
      return const Color(0xFF777772);
    default:
      return const Color(0xFF9A6D6D);
  }
}

String projectTypeLabel(String projectType, {String languageCode = 'ar'}) {
  final isArabic = languageCode == 'ar';
  switch (projectType) {
    case 'SPONSORED':
      return isArabic ? 'رعاية' : 'Sponsored';
    case 'FREE':
      return isArabic ? 'مجاني' : 'Free';
    case 'PAID':
    default:
      return isArabic ? 'مدفوع' : 'Paid';
  }
}
