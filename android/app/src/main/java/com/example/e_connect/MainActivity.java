package com.elsner.econnect;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.elsner.econnect/screen_share";

//    @Override
//    public void configureFlutterEngine(FlutterEngine flutterEngine) {
//        super.configureFlutterEngine(flutterEngine);
//
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//                .setMethodCallHandler(
//                        (call, result) -> {
//                            if (call.method.equals("startService")) {
//                                Intent intent = new Intent(this, ScreenShareForegroundService.class);
//                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                                    startForegroundService(intent);
//                                } else {
//                                    startService(intent);
//                                }
//                                result.success(null);
//                            } else if (call.method.equals("stopService")) {
//                                Intent intent = new Intent(this, ScreenShareForegroundService.class);
//                                stopService(intent);
//                                result.success(null);
//                            } else {
//                                result.notImplemented();
//                            }
//                        }
//                );
//    }
}
