package com.yourorg.permission_guard

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** PermissionGuardPlugin */
class PermissionGuardPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
  ActivityPluginBinding.RequestPermissionsResultListener {
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  private var pendingResult: MethodChannel.Result? = null
  private var pendingPermission: String? = null
  private val requestCode = 2247

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.yourorg.permission_guard")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
      "requestPermission" -> {
        val permName = call.argument<String>("permission") ?: run {
          result.error("ARG_ERROR", "Missing 'permission' argument", null)
          return
        }
        requestPermissionInternal(permName, result)
      }
      "openAppSettings" -> {
        val ctx = activity ?: run {
          result.success(false)
          return
        }
        try {
          val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
          intent.data = Uri.parse("package:" + ctx.packageName)
          ctx.startActivity(intent)
          result.success(true)
        } catch (e: Exception) {
          result.success(false)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun androidPermissionString(perm: String): String? {
    return when (perm) {
      "camera" -> android.Manifest.permission.CAMERA
      "microphone" -> android.Manifest.permission.RECORD_AUDIO
      "location" -> android.Manifest.permission.ACCESS_FINE_LOCATION
      else -> null
    }
  }

  private fun requestPermissionInternal(permission: String, result: MethodChannel.Result) {
    val act = activity ?: run {
      result.error("NO_ACTIVITY", "Plugin not attached to an Activity", null)
      return
    }
    val androidPerm = androidPermissionString(permission) ?: run {
      result.error("UNSUPPORTED", "Unsupported permission: $permission", null)
      return
    }
    val granted = ContextCompat.checkSelfPermission(act, androidPerm) == PackageManager.PERMISSION_GRANTED
    if (granted) {
      result.success("granted")
      return
    }
    if (pendingResult != null) {
      result.error("ALREADY_REQUESTING", "Another permission request is in progress", null)
      return
    }
    pendingResult = result
    pendingPermission = androidPerm
    ActivityCompat.requestPermissions(act, arrayOf(androidPerm), requestCode)
  }

  override fun onRequestPermissionsResult(rc: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    if (rc != requestCode) return false
    val res = pendingResult ?: return false
    val requested = pendingPermission
    pendingResult = null
    pendingPermission = null

    if (permissions.isNotEmpty() && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      res.success("granted")
      return true
    }
    val act = activity
    if (act != null && requested != null) {
      val shouldShow = ActivityCompat.shouldShowRequestPermissionRationale(act, requested)
      if (!shouldShow) {
        res.success("permanentlyDenied")
      } else {
        res.success("denied")
      }
    } else {
      res.success("denied")
    }
    return true
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // ActivityAware implementation
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
