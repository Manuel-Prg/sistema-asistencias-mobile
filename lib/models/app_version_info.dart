class AppVersionInfo {
  final String version;
  final int buildNumber;
  final String apkUrl;
  final String? changelog;
  final bool isMandatory;
  final DateTime? releaseDate;

  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.apkUrl,
    this.changelog,
    this.isMandatory = false,
    this.releaseDate,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      version: json['version'] as String? ?? '1.0.0',
      buildNumber: json['build_number'] as int? ?? 1,
      apkUrl: json['apk_url'] as String? ?? '',
      changelog: json['changelog'] as String?,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      releaseDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
