import 'package:flutter/material.dart';

String taskStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'معلّقة';
    case 'in_progress':
      return 'قيد التنفيذ';
    case 'done':
      return 'مكتملة';
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

String taskPriorityLabel(String? priority) {
  switch (priority) {
    case 'high':
      return 'عالية';
    case 'medium':
      return 'متوسطة';
    case 'low':
      return 'منخفضة';
    default:
      return 'غير محدد';
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
