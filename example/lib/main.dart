import 'package:flutter/material.dart';
import 'package:mega_blue/mega_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _platformVersion = 'Unknown';
  final _megaBluePlugin = MegaBlue();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    _megaBluePlugin.setListener((HeadsetState state) {
      print('Headset state: $state');
    });

    final state = await _megaBluePlugin.getCurrentState;
    print('Headset state: $state');

    final deviceName = await _megaBluePlugin.getDeviceName;
    print('Device name: $deviceName');

    final devices = await _megaBluePlugin.listAllAudioDevices;
    print('Devices: $devices');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
