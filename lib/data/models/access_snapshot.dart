class AccessSnapshot {
  final int permissionsVersion;
  final Set<String> screens;
  final Set<String> actions;
  final Set<String> features;
  final Map<String, dynamic> scopes;

  const AccessSnapshot({
    required this.permissionsVersion,
    required this.screens,
    required this.actions,
    required this.features,
    required this.scopes,
  });

  factory AccessSnapshot.fromJson(Map<String, dynamic> json) {
    final featureData = json['features'];
    final allowedFeatures = featureData is Map ? featureData['allowed'] : null;
    return AccessSnapshot(
      permissionsVersion: (json['permissionsVersion'] as num?)?.toInt() ?? 1,
      screens: _stringSet(json['screens']),
      actions: _stringSet(json['actions']),
      features: _stringSet(allowedFeatures),
      scopes: json['scopes'] is Map
          ? Map<String, dynamic>.from(json['scopes'] as Map)
          : const <String, dynamic>{},
    );
  }

  static Set<String> _stringSet(dynamic value) {
    if (value is! List) return <String>{};
    return value.map((entry) => entry.toString()).toSet();
  }
}
