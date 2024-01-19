import 'package:flutter/services.dart';

typedef DetectPluggedCallback = Function(HeadsetState payload);

enum HeadsetState {
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

  //Reads asynchronously the current state of the headset with type [HeadsetState]
  Future<HeadsetState?> get getCurrentState async {
    final state = await _channel.invokeMethod<int?>('getCurrentState');

    switch (state) {
      case 0:
        return HeadsetState.DISCONNECT;
      case 1:
        return HeadsetState.CONNECT;
      default:
        return HeadsetState.DISCONNECT;
    }
  }

  Future<String?> get getDeviceName async {
    return await _channel.invokeMethod<String>('getDeviceName');
  }

  Future<List<Object?>?> get listAllAudioDevices async {
    return _channel.invokeMethod<List<Object?>>('listAllAudioDevices');
  }

  //Sets a callback that is called whenever a change in [HeadsetState] happens.
  //Callback function [onPlugged] must accept a [HeadsetState] parameter.
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
        return callback(HeadsetState.CONNECT);
      case "disconnect":
        return callback(HeadsetState.DISCONNECT);
    }
  }
}
