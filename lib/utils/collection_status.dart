import 'package:flutter/material.dart';

String collectionStatusLabel(String status, {String languageCode = 'ar'}) {
  final isArabic = languageCode == 'ar';
  switch (status.trim().toUpperCase()) {
    case 'FULLY_COLLECTED':
      return isArabic ? 'محصل بالكامل' : 'Fully collected';
    case 'PARTIALLY_COLLECTED':
      return isArabic ? 'محصل جزئيًا' : 'Partially collected';
    case 'NOT_COLLECTED':
      return isArabic ? 'غير محصل' : 'Not collected';
    default:
      return isArabic ? 'حالة التحصيل غير معروفة' : 'Unknown collection status';
  }
}

Color collectionStatusColor(String status) {
  switch (status.trim().toUpperCase()) {
    case 'FULLY_COLLECTED':
      return const Color(0xFF6F8F83);
    case 'PARTIALLY_COLLECTED':
      return const Color(0xFF9A8468);
    case 'NOT_COLLECTED':
      return const Color(0xFF9A6D6D);
    default:
      return const Color(0xFF777772);
  }
}
