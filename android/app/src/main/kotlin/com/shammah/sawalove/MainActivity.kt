package com.shammah.sawalove

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    createIncomingCallChannel()
  }

  /**
   * The `notify-call` Edge Function targets this channel. Without it Android
   * drops the ring into the default (quiet) channel instead of buzzing, so the
   * channel must exist before the first push arrives.
   */
  private fun createIncomingCallChannel() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
    val manager = getSystemService(NotificationManager::class.java) ?: return
    if (manager.getNotificationChannel(CHANNEL_ID) != null) return

    val ringtone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
    val channel = NotificationChannel(
      CHANNEL_ID,
      "Incoming calls",
      NotificationManager.IMPORTANCE_HIGH,
    ).apply {
      description = "Ringing for SawaLove video calls"
      enableVibration(true)
      lockscreenVisibility = Notification.VISIBILITY_PUBLIC
      setSound(
        ringtone,
        AudioAttributes.Builder()
          .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
          .build(),
      )
    }
    manager.createNotificationChannel(channel)
  }

  private companion object {
    const val CHANNEL_ID = "incoming_calls"
  }
}
