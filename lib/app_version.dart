import 'package:package_info_plus/package_info_plus.dart';

/// Semantic Versioning (SemVer) for Meco.
///
/// The displayed application version is `MAJOR.MINOR.PATCH`:
///
///   MAJOR - breaking change / major official release (1.0.0 -> 2.0.0)
///   MINOR - new backward-compatible feature     (1.0.0 -> 1.1.0)
///   PATCH - bug fix / small improvement         (1.0.0 -> 1.0.1)
///
/// Examples:
///   1.0.0 -> initial stable release
///   1.0.1 -> bug fix
///   1.1.0 -> new feature
///   2.0.0 -> major/breaking release
///
/// Rules:
///   - pubspec.yaml is the single source of truth, e.g. `version: 1.0.0+1`.
///   - When MINOR increases, PATCH resets to 0 (1.0.5 -> 1.1.0, not 1.1.6).
///   - Versions are incremented intentionally by the developer before a
///     release; they are NEVER changed automatically by builds or commits.
///   - The build number (the value after "+") is never shown in the UI.
///   - Version increments do not happen automatically; the developer must
///     update pubspec.yaml explicitly when preparing a release.
class AppVersion {
  AppVersion._();

  /// Validates and normalizes a raw version string to `MAJOR.MINOR.PATCH`.
  ///
  /// Accepts "1.0.0" or "1.0.0+1" (build metadata is stripped).
  /// Rejects invalid versions such as "1", "1.0", "v1.0.0", "1.0.0.1",
  /// "1.0.0-rc.1" and returns null.
  static String? semanticFromRaw(String? raw) {
    if (raw == null) return null;
    final Match? match =
        RegExp(r'^(\d+)\.(\d+)\.(\d+)(\+|$)').firstMatch(raw.trim());
    if (match == null) return null;
    return '${match.group(1)}.${match.group(2)}.${match.group(3)}';
  }

  /// The installed application's `MAJOR.MINOR.PATCH` version, or null when
  /// the platform metadata is unavailable or not valid SemVer.
  static Future<String?> installedSemanticVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return semanticFromRaw(info.version);
  }
}
