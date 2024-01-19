import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mega_blue/mega_blue.dart';

void main() {
  runApp(const MyApp());
}

class Device {
  final String name;
  final String uid;

  Device(this.name, this.uid);

  factory Device.fromJson(Map<dynamic, dynamic> json) {
    return Device(json['name'], json['uid']);
  }

  @override
  String toString() {
    return 'Device{name: $name, id: $uid}';
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _megaBluePlugin = MegaBlue();
  final player = AudioPlayer();
  bool isConnected = false;
  final List<Device> allDevices = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    _megaBluePlugin.setListener((HeadsetState state) {
      log('Headset state: $state');
      if (state == HeadsetState.CONNECT) {
        getAllDevices();
      }
      setState(() {
        isConnected = state == HeadsetState.CONNECT;
      });
    });

    final state = await _megaBluePlugin.getCurrentState;
    log('Headset state: $state');
    if (state == HeadsetState.CONNECT) {
      await getAllDevices();
    }
    setState(() {
      isConnected = state == HeadsetState.CONNECT;
    });

    final deviceName = await _megaBluePlugin.getDeviceName;
    log('Device name: $deviceName');
  }

  Future<List<Device>> getAllDevices() async {
    final devices = await _megaBluePlugin.listAllAudioDevices;
    final deviceList = devices!
        .map((e) => Device.fromJson(e as Map<dynamic, dynamic>))
        .toList();
    setState(() {
      allDevices.addAll(deviceList);
    });
    return deviceList;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isConnected)
                Container(
                  color: Colors.amber,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          await _megaBluePlugin
                              .setAudioDevice(allDevices[index].uid);
                        },
                        child: Text(allDevices[index].name),
                      );
                    },
                    itemCount: allDevices.length,
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  await player.setUrl(
                      'https://cdn.freesound.org/previews/44/44811_409629-lq.mp3');
                  await player.play();
                },
                child: const Text('Play'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await player.stop();
                },
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
