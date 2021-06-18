package com.winner.dpos

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    /**
     * 通过 scheme 进来的
     */
    private var schemeUri: Uri? = null;

    /**
     * android 向 flutter发送参数
     */
    private var nativeToFlutter: MethodChannel? = null;
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        schemeUri = intent.data
        Log.i("TAG", "onCreate=====$schemeUri");
//        bundle = intent.getBundleExtra("BundleData");
        nativeToFlutter = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.winner.celodance/nativeToFlutter");
        MethodChannel(flutterEngine.dartExecutor, "com.winner.celodance/flutterToNative")
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "inHome" -> { //已经到达app首页面
                            schemeData();
                            result?.success("");
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        try {
            schemeUri = intent.data
            Log.i("TAG", "onNewIntent=====$schemeUri");
//            bundle = intent.getBundleExtra("BundleData");
            schemeData();
        } catch (e: Exception) {
        }
    }

    /**
     * 用于 scheme 跳转页面传值 数据传值
     */
    private fun schemeData() {
        schemeUri?.let {
            nativeToFlutter?.invokeMethod("SCHEME_DATA", schemeUri.toString());
            schemeUri = null;
        }
//        bundle?.let {
//            var argument = HashMap<String, Any>()
//            argument["key"] = it.getString("key", "");
//            argument["value"] = it.getString("value", "");
//            nativeToFlutter?.invokeMethod("push-home", argument);
//            bundle = null;
//        }
    }
}
