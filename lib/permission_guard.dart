import 'package:flutter/widgets.dart';

import 'permission_guard_platform_interface.dart';

/// Enum representing the native permission types.
enum Permission {
  camera,
  location,
  microphone,
  // Add more as needed
}

/// Enum representing the status of a permission.
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  // restricted (iOS specific) or limited (iOS photos specific)
  unknown,
}

class PermissionGuard {
  /// Returns a platform+version string, mainly for diagnostics.
  static Future<String?> getPlatformVersion() {
    return PermissionGuardPlatform.instance.getPlatformVersion();
  }

  /// Converts a native status string to the Dart enum.
  static PermissionStatus _parseStatus(String status) {
    switch (status) {
      case 'granted':
        return PermissionStatus.granted;
      case 'denied':
        return PermissionStatus.denied;
      case 'permanentlyDenied':
        return PermissionStatus.permanentlyDenied;
      default:
        return PermissionStatus.unknown;
    }
  }

  /// Imperative API: Requests a single permission from the user.
  static Future<PermissionStatus> request(Permission permission) async {
    final String permissionName = permission.name;
    try {
      final String? result = await PermissionGuardPlatform.instance
          .requestPermission(permissionName);
      if (result != null) {
        return _parseStatus(result);
      }
      return PermissionStatus.unknown;
    } catch (_) {
      return PermissionStatus.unknown;
    }
  }

  /// Imperative API: Opens the application settings screen.
  static Future<bool> openSettings() async {
    try {
      return await PermissionGuardPlatform.instance.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}

/// Declarative API: The core widget for state-aware UI.
class PermissionGuardWidget extends StatefulWidget {
  final Permission permission;
  final Widget Function(BuildContext) onGranted;
  final Widget Function(BuildContext) onChecking;
  final Widget Function(BuildContext, PermissionStatus) onDenied;
  final Widget Function(BuildContext) onPermanentlyDenied;

  const PermissionGuardWidget({
    super.key,
    required this.permission,
    required this.onGranted,
    required this.onChecking,
    required this.onDenied,
    required this.onPermanentlyDenied,
  });

  @override
  State<PermissionGuardWidget> createState() => _PermissionGuardWidgetState();
}

class _PermissionGuardWidgetState extends State<PermissionGuardWidget> {
  PermissionStatus _currentStatus = PermissionStatus.unknown;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    // 1. Check initial status
    PermissionStatus status = await PermissionGuard.request(widget.permission);

    if (!mounted) return;

    setState(() {
      _currentStatus = status;
      _isLoading = false;
    });

    // Note: The `request` method handles initial request logic.
    // In a final version, you would use a separate `status` check first
    // and then only call `request` if status is `denied`.
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.onChecking(context);
    }

    switch (_currentStatus) {
      case PermissionStatus.granted:
        return widget.onGranted(context);
      case PermissionStatus.denied:
        return widget.onDenied(context, _currentStatus);
      case PermissionStatus.permanentlyDenied:
        return widget.onPermanentlyDenied(context);
      case PermissionStatus.unknown:
        return widget.onChecking(context);
    }
  }
}
