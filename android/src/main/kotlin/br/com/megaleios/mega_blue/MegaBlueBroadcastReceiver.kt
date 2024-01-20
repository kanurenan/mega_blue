package br.com.megaleios.mega_blue

import android.content.BroadcastReceiver
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.Intent
import android.view.KeyEvent

class MegaBlueBroadcastReceiver(private val listener: MegaBlueEventListener) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
       when(intent?.action){
           Intent.ACTION_HEADSET_PLUG -> {
               when(intent.getIntExtra("state", -1)){
                   0 -> listener.onDisconnect()
                   1 -> listener.onConnect()
               }
           }
           BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED -> {
               when(intent.getIntExtra(BluetoothAdapter.EXTRA_CONNECTION_STATE, -1)){
                   BluetoothAdapter.STATE_DISCONNECTED -> listener.onDisconnect()
                   BluetoothAdapter.STATE_CONNECTED -> listener.onConnect()
               }
           }
           BluetoothAdapter.ACTION_STATE_CHANGED -> {
               when(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1)){
                   BluetoothAdapter.STATE_OFF -> listener.onDisconnect()
                   BluetoothAdapter.STATE_ON -> listener.onConnect()
               }
           }
       }
    }
}