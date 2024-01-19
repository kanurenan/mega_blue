import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mega_blue_method_channel.dart';

abstract class MegaBluePlatform extends PlatformInterface {
  /// Constructs a MegaBluePlatform.
  MegaBluePlatform() : super(token: _token);

  static final Object _token = Object();

  static MegaBluePlatform _instance = MethodChannelMegaBlue();

  /// The default instance of [MegaBluePlatform] to use.
  ///
  /// Defaults to [MethodChannelMegaBlue].
  static MegaBluePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MegaBluePlatform] when
  /// they register themselves.
  static set instance(MegaBluePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
