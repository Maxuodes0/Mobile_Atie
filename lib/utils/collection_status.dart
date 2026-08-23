import 'package:flutter/material.dart';

String collectionStatusLabel(String status) {
  switch (status.trim().toUpperCase()) {
    case 'FULLY_COLLECTED':
      return 'محصل بالكامل';
    case 'PARTIALLY_COLLECTED':
      return 'محصل جزئيًا';
    case 'NOT_COLLECTED':
      return 'غير محصل';
    default:
      return 'حالة التحصيل غير معروفة';
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
