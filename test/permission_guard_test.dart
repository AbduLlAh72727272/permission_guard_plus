import 'package:flutter_test/flutter_test.dart';
import 'package:permission_guard_plus/permission_guard.dart';
import 'package:permission_guard_plus/permission_guard_platform_interface.dart';
import 'package:permission_guard_plus/permission_guard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionGuardPlatform
    with MockPlatformInterfaceMixin
    implements PermissionGuardPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> requestPermission(String permission) => Future.value('granted');

  @override
  Future<bool> openAppSettings() => Future.value(true);
}

void main() {
  final PermissionGuardPlatform initialPlatform = PermissionGuardPlatform.instance;

  test('$MethodChannelPermissionGuard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPermissionGuard>());
  });

  test('getPlatformVersion', () async {
    MockPermissionGuardPlatform fakePlatform = MockPermissionGuardPlatform();
    PermissionGuardPlatform.instance = fakePlatform;

    expect(await PermissionGuard.getPlatformVersion(), '42');
  });
}
