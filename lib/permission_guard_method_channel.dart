import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'permission_guard_platform_interface.dart';

/// An implementation of [PermissionGuardPlatform] that uses method channels.
class MethodChannelPermissionGuard extends PermissionGuardPlatform {
  /// The method channel used to interact with the native platform.
  /// Keep this name consistent with the native plugin registrations.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.yourorg.permission_guard');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<String?> requestPermission(String permission) async {
    final result = await methodChannel.invokeMethod<String>(
      'requestPermission',
      {'permission': permission},
    );
    return result;
  }

  @override
  Future<bool> openAppSettings() async {
    final result = await methodChannel.invokeMethod<bool>('openAppSettings');
    return result ?? false;
  }
}
