import Flutter
import UIKit
import MidtransKit

public class SwiftFlutterMidtransPaymentPlugin: NSObject, FlutterPlugin, MidtransUIPaymentViewControllerDelegate {
	var result: FlutterResult? = nil
	
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
           let snapToken = myArgs["snap_token"] as? String,
           let environment = myArgs["environment"] as? String {
			self.result = result
            initSdk(clientKey: clientKey, merchantBaseUrl: merchantBaseUrl, environment: environment)
            self.payWithToken(token: snapToken)
        } else {
          result(FlutterError(code: "-1", message: "iOS could not extract " +
             "flutter arguments in method: (method)", details: nil))
        }
        
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func payWithToken(token: String) {
        MidtransMerchantClient.shared().requestTransacation(withCurrentToken: token) { (response, error) in
            if (response != nil){
                //present payment page
                let vc = MidtransUIPaymentViewController.init(token: response)
                vc?.paymentDelegate = self
				UIApplication.shared.keyWindow?.rootViewController?.present(vc!, animated: true, completion: nil)
            } else {
                print("error \(error!)");
            }
        }
    }
    
	private func initSdk(clientKey: String, merchantBaseUrl: String, environment: String) {
		if(environment == "production") {
			MidtransConfig.shared().setClientKey(
				clientKey,
				environment: .production,
				merchantServerURL: merchantBaseUrl
			);
	
		} else {
			MidtransConfig.shared().setClientKey(
				clientKey,
				environment: .sandbox,
				merchantServerURL: merchantBaseUrl
			);
		}
    }
    
//    #pragma mark - MidtransUIPaymentViewControllerDelegate
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentFailed error: Error!) {
		var data = [String: Any]()
		data["is_transaction_canceled"] = false
		data["source"] = "unknown"
		data["status"] = "failed"
		data["transaction_status"] = "unknown"
		data["status_message"] = "unknown"
		
		self.result?(FlutterError(code: "-1", message: "payment_failed", details: data))
    }
        
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentPending result: MidtransTransactionResult!) {
		var data = [String: Any]()
		data["is_transaction_canceled"] = false
		data["source"] = result.paymentType
		data["status"] = "success"
		data["transaction_status"] = result.transactionStatus
		data["status_message"] = result.statusMessage
		
		self.result?(data)
        
    }
        
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentSuccess result: MidtransTransactionResult!) {
		var data = [String: Any]()
		data["is_transaction_canceled"] = false
		data["source"] = result.paymentType
		data["status"] = "success"
		data["transaction_status"] = result.transactionStatus
		data["status_message"] = result.statusMessage
		
		self.result?(data)
    }

    public func paymentViewController_paymentCanceled(_ viewController: MidtransUIPaymentViewController!) {
		var data = [String: Any]()
		data["is_transaction_canceled"] = true
		data["source"] = "unknown"
		data["transaction_status"] = "unknown"
		data["status"] = "failed"
		data["status_message"] = "unknown"
		
		self.result?(FlutterError(code: "-1", message: "payment_canceled", details: data))
    }

    //This delegate methods is added on ios sdk v1.16.4 to handle the new3ds flow
    public func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentDeny result: MidtransTransactionResult!) {
		var data = [String: Any]()
		data["is_transaction_canceled"] = false
		data["source"] = result.paymentType
		data["transaction_status"] = result.transactionStatus
		data["status_message"] = result.statusMessage
		data["status"] = "failed"
		
		self.result?(FlutterError(code: "-1", message: "payment_deny", details: data))
    }
}
