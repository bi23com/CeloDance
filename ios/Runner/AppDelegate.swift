import UIKit
import Flutter

var flutterChannel:FlutterMethodChannel!
var nativeChannel:FlutterMethodChannel!

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var schemeUrl:String = ""
    var isHome = false;
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let currentVC = self.window.rootViewController as! FlutterViewController;
        flutterChannel = FlutterMethodChannel.init(name: Constants.flutterToNative, binaryMessenger: currentVC.binaryMessenger)
        nativeChannel = FlutterMethodChannel.init(name: Constants.nativeToFlutter, binaryMessenger: currentVC.binaryMessenger)
        flutterToNativeMethdCallHandler();
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func flutterToNativeMethdCallHandler(){
        flutterChannel.setMethodCallHandler { [self] (call, result) in
            print(">>>>>>>>>>>>>>>Flutter调用原生方法:\(call.method), 传值:\(String(describing: call.arguments))")
            switch (call.method) {
                case "inHome":
                    isHome = true;
                    if !schemeUrl.isEmpty {
                        //接收到scheme事件,通知flutter进行页面跳转
                        nativeChannel.invokeMethod("SCHEME_DATA", arguments: schemeUrl)
                        schemeUrl = ""
                    }
                    break
                default:
                    break;
            }
        }
    }

    ///iOS 9+ 应用唤起处理
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.hasPrefix("celodance://valora")){
            let urlStr = url.absoluteString.removingPercentEncoding ?? ""
            schemeUrl = urlStr
            if isHome && !schemeUrl.isEmpty {
                nativeChannel.invokeMethod("SCHEME_DATA", arguments: schemeUrl);
                schemeUrl = "";
            }
           
        }
        return true
    }
}


