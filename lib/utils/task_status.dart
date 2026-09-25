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
      return const Color(0xFF6F8F83);
    case 'in_progress':
      return const Color(0xFF687887);
    case 'pending':
    default:
      return const Color(0xFF9A8468);
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
      return const Color(0xFF9A6D6D);
    case 'medium':
      return const Color(0xFF9A8468);
    case 'low':
      return const Color(0xFF687887);
    default:
      return const Color(0xFF777772);
  }
}
