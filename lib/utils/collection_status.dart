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
      return const Color(0xFF16856B);
    case 'PARTIALLY_COLLECTED':
      return const Color(0xFFB7791F);
    case 'NOT_COLLECTED':
      return const Color(0xFFC2414B);
    default:
      return const Color(0xFF6B7280);
  }
}
