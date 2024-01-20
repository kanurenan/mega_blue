package br.com.megaleios.mega_blue

import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** MegaBluePlugin */
class MegaBluePlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        var currentState = -1
    }

    private lateinit var audioManager: AudioManager

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private val eventListener = object : MegaBlueEventListener {
        override fun onConnect() {
            currentState = 1
            channel.invokeMethod("connect", "true")
        }

        override fun onDisconnect() {
            currentState = 0
            channel.invokeMethod("disconnect", "true")
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "megaflutter/mega_blue")
        channel.setMethodCallHandler(this)

        val hReceiver = MegaBlueBroadcastReceiver(eventListener)
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_HEADSET_PLUG)
            addAction(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED)
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        }

        flutterPluginBinding.applicationContext.registerReceiver(hReceiver, filter)

        audioManager =
            flutterPluginBinding.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        currentState = if (getConnectedBlue(audioManager)) 1 else 0
    }

    private fun getConnectedBlue(audioManager: AudioManager): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return audioManager.isWiredHeadsetOn || audioManager.isBluetoothA2dpOn || audioManager.isBluetoothScoOn
        } else {
            val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)

            for (device in devices) {
                when (device.type) {
                    AudioDeviceInfo.TYPE_BLUETOOTH_A2DP -> return true
                }
            }
            return false
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCurrentState" -> {
                currentState = if (getConnectedBlue(audioManager)) 1 else 0
                result.success(currentState)
            }

            "getDeviceName" -> {
                val deviceName = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                    .firstOrNull {
                        it.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP
                    }?.productName
                result.success(deviceName)
            }

            "listAllAudioDevices" -> {
                val bluetoothDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                    .filter {
                        it.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP
                    }
                val devices = bluetoothDevices.map {
                    mapOf(
                        "name" to it.productName,
                        "uid" to it.id.toString(),
                    )
                }
                result.success(devices)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
