import Flutter
import UIKit
import MidtransKit

public class SwiftFlutterMidtransPaymentPlugin: NSObject, FlutterPlugin, MidtransUIPaymentViewControllerDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_midtrans_payment", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterMidtransPaymentPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "getPlatformVersion") {
        result("iOS " + UIDevice.current.systemVersion)
    } else if(call.method == "pay") {
    } else if(call.method == "payWithToken") {
        guard let args = call.arguments else {
          return
        }
        
        if let myArgs = args as? [String: Any],
           let clientKey = myArgs["client_key"] as? String,
           let merchantBaseUrl = myArgs["merchant_base_url"] as? String,
           let snapToken = myArgs["snap_token"] as? String {
            result("Params received on iOS = \(clientKey), \(merchantBaseUrl), \(snapToken)")
            initSdk(clientKey: clientKey, merchantBaseUrl: merchantBaseUrl)
            MidtransMerchantClient.init().requestTransacation(withCurrentToken: snapToken) { (response, error) in
            
				self.payWithToken(token: snapToken)
            }
            
        } else {
          result(FlutterError(code: "-1", message: "iOS could not extract " +
             "flutter arguments in method: (method)", details: nil))
        }
        
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func payWithToken(token: String) {
        let tokenResponse = MidtransTransactionTokenResponse.init()
        tokenResponse.tokenId = token
        
        let vc = MidtransUIPaymentViewController.init(token: tokenResponse)
        vc?.paymentDelegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(vc!, animated: true, completion: nil)
    }
    
    private func initSdk(clientKey: String, merchantBaseUrl: String) {
       MidtransConfig.shared().setClientKey(
        clientKey,
        environment: .sandbox,
        merchantServerURL: merchantBaseUrl
       );
    }
    
//    #pragma mark - MidtransUIPaymentViewControllerDelegate

    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentFailed error: Error!) {
        
    }
        
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentPending result: MidtransTransactionResult!) {
        
    }
        
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentSuccess result: MidtransTransactionResult!) {
        
    }

    public func paymentViewController_paymentCanceled(_ viewController: MidtransUIPaymentViewController!) {
        
    }

    //This delegate methods is added on ios sdk v1.16.4 to handle the new3ds flow
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentDeny result: MidtransTransactionResult!) {
    }
}
