import 'package:flutter/material.dart';

String taskStatusLabel(String status, {String languageCode = 'ar'}) {
  final isArabic = languageCode == 'ar';
  switch (status) {
    case 'pending':
      return isArabic ? 'معلّقة' : 'Pending';
    case 'in_progress':
      return isArabic ? 'قيد التنفيذ' : 'In progress';
    case 'done':
      return isArabic ? 'مكتملة' : 'Completed';
    default:
      return status;
  }
}

Color taskStatusColor(String status) {
  switch (status) {
    case 'done':
      return const Color(0xFF10B981);
    case 'in_progress':
      return const Color(0xFF3B82F6);
    case 'pending':
    default:
      return const Color(0xFFF59E0B);
  }
}

String taskPriorityLabel(String? priority, {String languageCode = 'ar'}) {
  final isArabic = languageCode == 'ar';
  switch (priority) {
    case 'high':
      return isArabic ? 'عالية' : 'High';
    case 'medium':
      return isArabic ? 'متوسطة' : 'Medium';
    case 'low':
      return isArabic ? 'منخفضة' : 'Low';
    default:
      return isArabic ? 'غير محدد' : 'Not set';
  }
}

Color taskPriorityColor(String? priority) {
  switch (priority) {
    case 'high':
      return const Color(0xFFEF4444);
    case 'medium':
      return const Color(0xFFF59E0B);
    case 'low':
      return const Color(0xFF6B7280);
    default:
      return const Color(0xFF9CA3AF);
  }
}
