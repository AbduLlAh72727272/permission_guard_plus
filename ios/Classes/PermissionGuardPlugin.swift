import Flutter
import UIKit
import AVFoundation
import CoreLocation

public class SwiftPermissionGuardPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
  var locationManager: CLLocationManager?
  var locationResult: FlutterResult?
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.yourorg.permission_guard", binaryMessenger: registrar.messenger())
    let instance = SwiftPermissionGuardPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "requestPermission":
      guard let args = call.arguments as? [String: Any], let perm = args["permission"] as? String else {
        result(FlutterError(code: "ARG_ERROR", message: "Missing 'permission' argument", details: nil))
        return
      }
      requestPermission(perm: perm, result: result)
    case "openAppSettings":
      // Attempt to open app settings; if it fails return false.
      if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        result(true)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestPermission(perm: String, result: @escaping FlutterResult) {
    switch perm {
    case "camera":
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      if status == .authorized {
        result("granted")
      } else if status == .denied || status == .restricted {
        result("permanentlyDenied")
      } else {
        AVCaptureDevice.requestAccess(for: .video) { granted in
          DispatchQueue.main.async {
            result(granted ? "granted" : "denied")
          }
        }
      }
    case "microphone":
      switch AVAudioSession.sharedInstance().recordPermission {
      case .granted: result("granted")
      case .denied: result("permanentlyDenied")
      case .undetermined:
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          DispatchQueue.main.async { result(granted ? "granted" : "denied") }
        }
      @unknown default:
        result("unknown")
      }
    case "location":
      handleLocationPermission(result: result)
    default:
      result(FlutterError(code: "UNSUPPORTED", message: "Unsupported permission: \(perm)", details: nil))
    }
  }

  private func handleLocationPermission(result: @escaping FlutterResult) {
    let lm = CLLocationManager()
    locationManager = lm
    lm.delegate = self
    self.locationResult = result
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      result("granted")
    case .denied, .restricted:
      result("permanentlyDenied")
    case .notDetermined:
      lm.requestWhenInUseAuthorization()
    @unknown default:
      result("unknown")
    }
  }

  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard let res = locationResult else { return }
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      res("granted")
    case .denied, .restricted:
      res("permanentlyDenied")
    case .notDetermined:
      break
    @unknown default:
      res("unknown")
    }
    locationResult = nil
    locationManager = nil
  }
}
