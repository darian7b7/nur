package com.darian.nur

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle

// Health Connect asks each app to explain why it reads health data. Nūr's answer is its privacy policy.
class PrivacyActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_URL)))
        } catch (_: Exception) {
            // No browser: nothing to show.
        }
        finish()
    }

    companion object {
        const val PRIVACY_URL = "https://darian7b7.github.io/nur/privacy.html"
    }
}
