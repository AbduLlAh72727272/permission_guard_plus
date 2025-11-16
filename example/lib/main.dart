import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_guard_plus/permission_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await PermissionGuard.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final status = await PermissionGuard.request(Permission.camera);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera permission: $status')));
                },
                child: const Text('Request Camera Permission'),
              ),
              SizedBox(height: 24),
              // Example of the PermissionGuardWidget usage
              Builder(builder: (ctx) {
                return PermissionGuardWidget(
                  permission: Permission.camera,
                  onChecking: (_) => const CircularProgressIndicator(),
                  onGranted: (_) => const Text('Permission granted — show feature'),
                  onDenied: (_, __) => ElevatedButton(
                    onPressed: () => PermissionGuard.request(Permission.camera),
                    child: const Text('Request Again'),
                  ),
                  onPermanentlyDenied: (_) => ElevatedButton(
                    onPressed: () => PermissionGuard.openSettings(),
                    child: const Text('Open Settings'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
