import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/utils/logger.dart';
import '../models/app_update_info.dart';
import '../config/api_config.dart';
import 'api_service.dart';

enum UpdateErrorType {
  network,
  invalidResponse,
  permission,
  download,
  hashMismatch,
  install,
  insecureUrl,
  unsupportedPlatform,
  unknown,
}

class UpdateException implements Exception {
  final UpdateErrorType type;
  final String message;
  final bool openSettings;

  const UpdateException(
    this.type,
    this.message, {
    this.openSettings = false,
  });

  @override
  String toString() => message;
}

class AppUpdateService {
  AppUpdateService({
    http.Client? httpClient,
    Dio? dio,
  })  : _httpClient = httpClient ?? http.Client(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(minutes: 2),
              ),
            );

  final http.Client _httpClient;
  final Dio _dio;

  Future<AppUpdateDecision> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = _normalizeVersion(packageInfo.version);

    if (currentVersion.isEmpty) {
      throw const UpdateException(
        UpdateErrorType.invalidResponse,
        'Unable to determine current app version.',
      );
    }

    final updateUri = Uri.parse('${ApiService.baseUrl}${ApiConfig.appUpdate}');
    Logger.i('AppUpdate', 'Checking update: $updateUri');

    final response = await _httpClient
        .get(updateUri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw UpdateException(
        UpdateErrorType.network,
        'Update check failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const UpdateException(
        UpdateErrorType.invalidResponse,
        'Invalid update response format.',
      );
    }

    final info = AppUpdateInfo.fromJson(decoded);
    if (info.latestVersion.isEmpty || info.minimumSupportedVersion.isEmpty) {
      throw const UpdateException(
        UpdateErrorType.invalidResponse,
        'Update information is incomplete.',
      );
    }

    final minCompare = _compareVersions(
      currentVersion,
      _normalizeVersion(info.minimumSupportedVersion),
    );
    if (minCompare < 0) {
      return AppUpdateDecision(
        requirement: UpdateRequirement.force,
        currentVersion: currentVersion,
        info: info,
      );
    }

    final latestCompare = _compareVersions(
      currentVersion,
      _normalizeVersion(info.latestVersion),
    );
    if (latestCompare < 0) {
      return AppUpdateDecision(
        requirement: UpdateRequirement.optional,
        currentVersion: currentVersion,
        info: info,
      );
    }

    return AppUpdateDecision(
      requirement: UpdateRequirement.none,
      currentVersion: currentVersion,
    );
  }

  Future<void> downloadAndInstall(
    AppUpdateInfo info, {
    void Function(double progress)? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      throw const UpdateException(
        UpdateErrorType.unsupportedPlatform,
        'In-app updates are only supported on Android.',
      );
    }

    if (info.apkUrl.isEmpty) {
      throw const UpdateException(
        UpdateErrorType.invalidResponse,
        'APK URL is missing from update configuration.',
      );
    }

    if (info.sha256.isEmpty) {
      throw const UpdateException(
        UpdateErrorType.invalidResponse,
        'SHA256 checksum is missing from update configuration.',
      );
    }

    if (!info.apkUrl.toLowerCase().startsWith('https://')) {
      throw const UpdateException(
        UpdateErrorType.insecureUrl,
        'APK download must use HTTPS.',
      );
    }

    await _ensurePermissions();

    final tempDir = Directory.systemTemp;
    final apkPath =
        '${tempDir.path}${Platform.pathSeparator}attendmark_v${info.latestVersion}.apk';

    final apkFile = File(apkPath);
    if (await apkFile.exists()) {
      await apkFile.delete();
    }

    try {
      await _dio.download(
        info.apkUrl,
        apkPath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
    } on DioException catch (e) {
      Logger.e('AppUpdate', 'Download failed', e);
      throw const UpdateException(
        UpdateErrorType.download,
        'Failed to download update. Please try again.',
      );
    }

    final hash = await _computeSha256(apkFile);
    if (hash.toLowerCase() != info.sha256.toLowerCase()) {
      throw const UpdateException(
        UpdateErrorType.hashMismatch,
        'Downloaded file verification failed.',
      );
    }

    try {
      final result = await OpenFilex.open(apkPath);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      Logger.e('AppUpdate', 'Install failed', e);
      throw const UpdateException(
        UpdateErrorType.install,
        'Failed to start installation. Please retry.',
      );
    }
  }

  Future<void> _ensurePermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt < 33) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        throw UpdateException(
          UpdateErrorType.permission,
          'Storage permission is required to download the update.',
          openSettings: storageStatus.isPermanentlyDenied,
        );
      }
    }

    final installStatus = await Permission.requestInstallPackages.request();
    if (!installStatus.isGranted) {
      throw UpdateException(
        UpdateErrorType.permission,
        'Allow installs from unknown sources to continue.',
        openSettings: installStatus.isPermanentlyDenied,
      );
    }
  }

  Future<String> _computeSha256(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _normalizeVersion(String version) {
    final trimmed = version.trim();
    if (trimmed.isEmpty) return '';

    final withoutBuild = trimmed.split('+').first;
    return withoutBuild.split('-').first.trim();
  }

  int _compareVersions(String a, String b) {
    final aParts = _splitVersion(a);
    final bParts = _splitVersion(b);

    final maxLength = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < maxLength; i++) {
      final aValue = i < aParts.length ? aParts[i] : 0;
      final bValue = i < bParts.length ? bParts[i] : 0;

      if (aValue != bValue) {
        return aValue.compareTo(bValue);
      }
    }

    return 0;
  }

  List<int> _splitVersion(String version) {
    if (version.isEmpty) return <int>[];
    final parts = version.split('.');

    return parts
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList(growable: false);
  }
}
