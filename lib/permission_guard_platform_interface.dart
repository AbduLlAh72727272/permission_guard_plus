import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'permission_guard_method_channel.dart';

abstract class PermissionGuardPlatform extends PlatformInterface {
  /// Constructs a PermissionGuardPlatform.
  PermissionGuardPlatform() : super(token: _token);

  static final Object _token = Object();

  static PermissionGuardPlatform _instance = MethodChannelPermissionGuard();

  /// The default instance of [PermissionGuardPlatform] to use.
  ///
  /// Defaults to [MethodChannelPermissionGuard].
  static PermissionGuardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PermissionGuardPlatform] when
  /// they register themselves.
  static set instance(PermissionGuardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the platform/version string provided by the platform implementation.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Requests the given [permission] from the platform and returns a
  /// platform-specific status string (e.g. 'granted', 'denied', 'permanentlyDenied').
  Future<String?> requestPermission(String permission) {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  /// Opens the app settings screen. Returns true if the call was successful.
  Future<bool> openAppSettings() {
    throw UnimplementedError('openAppSettings() has not been implemented.');
  }
}
