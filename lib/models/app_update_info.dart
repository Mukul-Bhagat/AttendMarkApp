class AppUpdateInfo {
  final String latestVersion;
  final String minimumSupportedVersion;
  final String releaseNotes;
  final String apkUrl;
  final String sha256;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.releaseNotes,
    required this.apkUrl,
    required this.sha256,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersion: (json['latestVersion'] ?? '').toString().trim(),
      minimumSupportedVersion:
          (json['minimumSupportedVersion'] ?? '').toString().trim(),
      releaseNotes: (json['releaseNotes'] ?? '').toString(),
      apkUrl: (json['apkUrl'] ?? '').toString().trim(),
      sha256: (json['sha256'] ?? '').toString().trim(),
    );
  }
}

enum UpdateRequirement {
  none,
  optional,
  force,
}

class AppUpdateDecision {
  final UpdateRequirement requirement;
  final AppUpdateInfo? info;
  final String currentVersion;

  const AppUpdateDecision({
    required this.requirement,
    required this.currentVersion,
    this.info,
  });
}
