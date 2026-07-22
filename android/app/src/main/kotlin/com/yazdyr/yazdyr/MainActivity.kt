package com.yazdyr.yazdyr

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Opens a URL in the browser / relevant app. Replaces url_launcher, which
    // isn't available in the offline build.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "yazdyr/url")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "open" -> {
                        val url = call.arguments as String
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                    "sms" -> {
                        // Opens the SMS composer pre-filled; the owner reviews and
                        // sends from their own number. No SEND_SMS permission needed.
                        val args = call.arguments as Map<*, *>
                        val intent = Intent(
                            Intent.ACTION_SENDTO,
                            Uri.parse("smsto:${args["phone"]}")
                        )
                            .putExtra("sms_body", args["body"] as String)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                    "smsSend" -> {
                        // ponytail: silent send needs the SEND_SMS permission, which
                        // Google Play restricts — opt-in only (Settings, off by
                        // default). On first use we request the permission and return
                        // false so Dart falls back to the composer this once.
                        val args = call.arguments as Map<*, *>
                        if (ContextCompat.checkSelfPermission(
                                this, Manifest.permission.SEND_SMS)
                            == PackageManager.PERMISSION_GRANTED) {
                            val sms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
                                getSystemService(SmsManager::class.java)
                            else
                                @Suppress("DEPRECATION") SmsManager.getDefault()
                            val body = args["body"] as String
                            sms.sendMultipartTextMessage(
                                args["phone"] as String, null,
                                sms.divideMessage(body), null, null)
                            result.success(true)
                        } else {
                            ActivityCompat.requestPermissions(
                                this, arrayOf(Manifest.permission.SEND_SMS), 1001)
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
