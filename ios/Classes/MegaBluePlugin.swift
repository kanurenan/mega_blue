import Flutter
import UIKit
import AVFoundation

public class MegaBluePlugin: NSObject, FlutterPlugin {
    var channel : FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mega_blue", binaryMessenger: registrar.messenger())
        let instance = MegaBluePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel )
        instance.channel = channel
    }
    
    private let PLATFORM_VERSION = "getPlatformVersion"
    private let GET_DEVICE_LIST = "getDeviceList"
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case PLATFORM_VERSION:
            result("iOS " + UIDevice.current.systemVersion)
            break;
        case GET_DEVICE_LIST:
            result("iOS " + UIDevice.current.systemVersion)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public override init() {
        super.init()
        registerAudioRouteChangeBlock()
    }
    
    func registerAudioRouteChangeBlock(){
        NotificationCenter.default.addObserver( forName:AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance(), queue: nil) { notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
            }
            switch reason {
            case .newDeviceAvailable:
                self.channel!.invokeMethod("connect",arguments: "true")
            case .oldDeviceUnavailable:
                self.channel!.invokeMethod("disconnect",arguments: "true")
            default: ()
            }
        }
    }
}
