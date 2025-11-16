// Conditional export: use dart:io-backed detector where available, otherwise stub.
export 'platform_detector_stub.dart'
    if (dart.library.io) 'platform_detector_io.dart';
