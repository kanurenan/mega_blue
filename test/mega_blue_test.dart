import 'package:flutter_test/flutter_test.dart';
import 'package:mega_blue/mega_blue.dart';
import 'package:mega_blue/mega_blue_platform_interface.dart';
import 'package:mega_blue/mega_blue_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMegaBluePlatform
    with MockPlatformInterfaceMixin
    implements MegaBluePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MegaBluePlatform initialPlatform = MegaBluePlatform.instance;

  test('$MethodChannelMegaBlue is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMegaBlue>());
  });

  test('getPlatformVersion', () async {
    MegaBlue megaBluePlugin = MegaBlue();
    MockMegaBluePlatform fakePlatform = MockMegaBluePlatform();
    MegaBluePlatform.instance = fakePlatform;

    expect(await megaBluePlugin.getPlatformVersion(), '42');
  });
}
