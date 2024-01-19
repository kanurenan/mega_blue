import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'mega_blue_platform_interface.dart';

/// An implementation of [MegaBluePlatform] that uses method channels.
class MethodChannelMegaBlue extends MegaBluePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mega_blue');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> isDeviceConnected() async {
    final isConnected =
        await methodChannel.invokeMethod<bool>('isDeviceConnected');
    return isConnected;
  }

  @override
  Future<void> checkPermission() async {
    final isGranted = await Permission.bluetooth.isGranted;
    if (!isGranted) {
      await Permission.bluetooth.request();
    }
  }
}
