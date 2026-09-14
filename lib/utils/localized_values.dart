String localizedAccountRole(String value, String languageCode) {
  final isArabic = languageCode == 'ar';
  switch (value.trim().toUpperCase()) {
    case 'ADMIN':
      return isArabic ? 'مدير النظام' : 'Administrator';
    case 'PROGRAM_MANAGER':
      return isArabic ? 'مدير البرنامج' : 'Program Manager';
    case 'PROJECT_MANAGER':
      return isArabic ? 'مدير مشروع' : 'Project Manager';
    case 'EMPLOYEE':
      return isArabic ? 'موظف' : 'Employee';
    case 'FREELANCER':
      return isArabic ? 'فريلانسر' : 'Freelancer';
    default:
      return value;
  }
}

String localizedEmploymentStatus(String value, String languageCode) {
  final isArabic = languageCode == 'ar';
  switch (value.trim().toUpperCase()) {
    case 'ACTIVE':
      return isArabic ? 'نشط' : 'Active';
    case 'INACTIVE':
      return isArabic ? 'غير نشط' : 'Inactive';
    case 'ON_LEAVE':
      return isArabic ? 'في إجازة' : 'On leave';
    default:
      return value;
  }
}

String localizedPaymentMethod(String value, String languageCode) {
  final isArabic = languageCode == 'ar';
  switch (value.trim().toUpperCase()) {
    case 'BANK_TRANSFER':
    case 'TRANSFER':
      return isArabic ? 'تحويل بنكي' : 'Bank transfer';
    case 'CASH':
      return isArabic ? 'نقدًا' : 'Cash';
    case 'CARD':
      return isArabic ? 'بطاقة' : 'Card';
    case 'CHEQUE':
    case 'CHECK':
      return isArabic ? 'شيك' : 'Cheque';
    default:
      return value;
  }
}
