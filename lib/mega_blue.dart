import 'mega_blue_platform_interface.dart';

class MegaBlue {
  Future<String?> getPlatformVersion() {
    return MegaBluePlatform.instance.getPlatformVersion();
  }

  Future<bool?> isDeviceConnected() {
    return MegaBluePlatform.instance.isDeviceConnected();
  }
}
