import 'permission_guard_platform_interface.dart';

/// A lightweight Dart-only implementation used on Web and desktop platforms
/// where native permission flows are not implemented. Returns conservative
/// default values so apps can handle missing support gracefully.
class StubPermissionGuard extends PermissionGuardPlatform {
  @override
  Future<String?> getPlatformVersion() async => 'dart';

  @override
  Future<String?> requestPermission(String permission) async {
    // On non-mobile platforms, report 'unknown' so the UI may show a fallback.
    return 'unknown';
  }

  @override
  Future<bool> openAppSettings() async {
    return false;
  }
}
