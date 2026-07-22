package com.yazdyr.yazdyr

import android.content.Intent
import android.net.Uri
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
                    else -> result.notImplemented()
                }
            }
    }
}
