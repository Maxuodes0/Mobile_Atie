class ProjectRoleLabel {
  const ProjectRoleLabel({required this.nameEn, required this.nameAr});

  final String nameEn;
  final String nameAr;

  factory ProjectRoleLabel.fromJson(Map<String, dynamic> json) {
    return ProjectRoleLabel(
      nameEn: json['nameEn']?.toString().trim() ?? '',
      nameAr: json['nameAr']?.toString().trim() ?? '',
    );
  }

  bool matches(String value) {
    final normalized = value.trim().toLowerCase();
    return nameEn.toLowerCase() == normalized ||
        nameAr.toLowerCase() == normalized;
  }

  String localized(String languageCode) {
    if (languageCode == 'ar') return nameAr.isEmpty ? nameEn : nameAr;
    return nameEn.isEmpty ? nameAr : nameEn;
  }
}
