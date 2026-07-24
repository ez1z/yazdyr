package com.yazdyr.yazdyr

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    // Holds the pending import() result across the ACTION_OPEN_DOCUMENT round-trip.
    private var importResult: MethodChannel.Result? = null
    private val reqImport = 4711

    // Opens a URL in the browser / relevant app. Replaces url_launcher, which
    // isn't available in the offline build.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Backup share/import via native intents (share_plus / file_picker are
        // uncached offline). No dependency — just Android intents.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "yazdyr/backup")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "share" -> {
                        val args = call.arguments as Map<*, *>
                        val file = File(args["path"] as String)
                        val mime = args["mime"] as? String ?: "application/octet-stream"
                        val uri = FileProvider.getUriForFile(
                            this, "$packageName.fileprovider", file
                        )
                        val send = Intent(Intent.ACTION_SEND)
                            .setType(mime)
                            .putExtra(Intent.EXTRA_STREAM, uri)
                            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        startActivity(
                            Intent.createChooser(send, null)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(null)
                    }
                    "import" -> {
                        importResult = result
                        val pick = Intent(Intent.ACTION_OPEN_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            .setType("*/*") // some pickers hide .json under a json filter
                        startActivityForResult(pick, reqImport)
                    }
                    else -> result.notImplemented()
                }
            }

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

    // Delivers the picked file's text back to the pending import() call.
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != reqImport) return
        val r = importResult
        importResult = null
        val uri = data?.data
        if (resultCode == Activity.RESULT_OK && uri != null) {
            try {
                val text = contentResolver.openInputStream(uri)!!
                    .bufferedReader().use { it.readText() }
                r?.success(text)
            } catch (e: Exception) {
                r?.error("read_failed", e.message, null)
            }
        } else {
            r?.success(null) // cancelled
        }
    }
}
