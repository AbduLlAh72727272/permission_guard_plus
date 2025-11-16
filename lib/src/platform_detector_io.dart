// IO-backed platform detection for non-web platforms.
import 'dart:io' show Platform;

bool get isWeb => false;
bool get isWindows => Platform.isWindows;
bool get isLinux => Platform.isLinux;
bool get isMacOS => Platform.isMacOS;
