package com.adrytentaciones.presupuestos

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.io.File

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // printing shares from cache/share. The previous session's PDF must
        // never be available when the app starts a fresh session.
        File(cacheDir, "share").listFiles()?.forEach { file ->
            if (file.isFile) file.delete()
        }
        super.onCreate(savedInstanceState)
    }
}
