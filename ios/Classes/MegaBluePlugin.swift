import Flutter
import UIKit
import AVFoundation
import CoreBluetooth

public class MegaBluePlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate {
    var channel : FlutterMethodChannel?
    var peripheral: CBPeripheral?
    var centralManager: CBCentralManager!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "megaflutter/mega_blue", binaryMessenger: registrar.messenger())
        let instance = MegaBluePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel )
        instance.channel = channel
    }
    
    private let CURRENT_STATE = "getCurrentState"
    private let DEVICE_NAME = "getDeviceName"
    private let LIST_DEVICES = "listAllAudioDevices"
    private let CONNECT = "connect"
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth não está disponível.")
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case CURRENT_STATE:
            result(HeadsetIsConnect())
            break;
        case DEVICE_NAME:
            result(HeadsetDeviceName())
            break;
        case LIST_DEVICES:
            result(ListOutputDevices())
            break;
        case CONNECT:
            let uid = call.arguments as! String
            ConnectHeadset(uid: uid)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public override init() {
        super.init()
        registerAudioRouteChangeBlock()
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
    
    func HeadsetIsConnect() -> Int  {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            let portType = output.portType
            if portType == AVAudioSession.Port.headphones || portType == AVAudioSession.Port.bluetoothA2DP || portType == AVAudioSession.Port.bluetoothHFP {
                return 1
            } else {
                return 0
            }
        }
        return 0
    }
    
    func HeadsetDeviceName() -> String {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            let portName = output.portName
            return portName
        }
        return ""
    }
    
    func ListOutputDevices() -> [[String: String]] {
        var outputDevices: [[String: String]] = []
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            let portName = output.portName
            let uid = output.uid
            outputDevices.append(["name": portName, "uid": uid])
        }
        return outputDevices
    }
    
    func ConnectHeadset(uid: String) {
        print("ConnectHeadset")
        print(uid)
        let targetPeripheralUUID = UUID(uuidString: uid)
        if peripheral?.identifier == targetPeripheralUUID {
            centralManager.stopScan()
            centralManager.connect(peripheral!, options: nil)
        }
    }
}
