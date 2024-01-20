// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';

typedef DetectPluggedCallback = Function(MegaBlueState payload);

enum MegaBlueState {
  CONNECT,
  DISCONNECT,
}

class MegaBlue {
  static MegaBlue? _instance;

  final MethodChannel _channel;

  DetectPluggedCallback? _detectPluggedCallback;

  MegaBlue.private(this._channel);

  factory MegaBlue() {
    if (_instance == null) {
      const methodChannel = MethodChannel('megaflutter/mega_blue');
      _instance = MegaBlue.private(methodChannel);
    }

    return _instance!;
  }

  ///Returns the current state of the bluetooth.
  ///If the bluetooth is connected, it will return MegaBlueState.CONNECT.
  ///If the bluetooth is disconnected, it will return MegaBlueState.DISCONNECT.
  Future<MegaBlueState?> get getCurrentState async {
    final state = await _channel.invokeMethod<int?>('getCurrentState');

    switch (state) {
      case 0:
        return MegaBlueState.DISCONNECT;
      case 1:
        return MegaBlueState.CONNECT;
      default:
        return MegaBlueState.DISCONNECT;
    }
  }

  Future<String?> get getDeviceName async {
    return await _channel.invokeMethod<String>('getDeviceName');
  }

  ///Returns a list of all connected audio devices.
  ///The list contains List<Object?> objects, with name and uid from the device.
  ///If no device is connected, the list will be empty.
  Future<List<Object?>> get listAllAudioDevices async {
    await Future.delayed(const Duration(milliseconds: 300));
    return await _channel.invokeMethod<List<Object?>>('listAllAudioDevices') ??
        [];
  }

  ///This method is used to set the callback for the bluetooth state.
  ///The callback will return the current state of the bluetooth.
  void setListener(DetectPluggedCallback onPlugged) {
    _detectPluggedCallback = onPlugged;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    final callback = _detectPluggedCallback;
    if (callback == null) {
      return;
    }

    switch (call.method) {
      case "connect":
        return callback(MegaBlueState.CONNECT);
      case "disconnect":
        return callback(MegaBlueState.DISCONNECT);
    }
  }

  setAudioDevice(String uid) {
    _channel.invokeMethod('connect', uid);
  }
}
