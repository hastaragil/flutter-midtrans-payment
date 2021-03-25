package com.hastaragil.flutter_midtrans_payment

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.midtrans.sdk.corekit.core.MidtransSDK
import com.midtrans.sdk.corekit.core.PaymentMethod
import com.midtrans.sdk.corekit.core.TransactionRequest
import com.midtrans.sdk.uikit.SdkUIFlowBuilder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*


/** FlutterMidtransPaymentPlugin */
class FlutterMidtransPaymentPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//      TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
      this.activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
//      TODO("Not yet implemented")
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_midtrans_payment")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "pay" -> {
                val clientKey = call.argument<String>("client_key")
                val merchantBaseUrl = call.argument<String>("merchant_base_url")
                val orderId = call.argument<String>("order_id")
                val totalPrice = call.argument<Double>("total_price")

                var selectedPaymentMethod = -1
                if(call.hasArgument("selected_payment_method")) {
                  selectedPaymentMethod = call.argument<Int>("selected_payment_method") ?: -1
                }

                val arguments = HashMap<String, Any>()
                arguments["client_key"] = clientKey as Any
                arguments["merchant_base_url"] = merchantBaseUrl as Any
                arguments["order_id"] = orderId as Any
                arguments["total_price"] = totalPrice as Any
                arguments["selected_payment_method"] = selectedPaymentMethod as Any
                pay(arguments, result)
            }
            "payWithToken" -> {
                val clientKey = call.argument<String>("client_key")
                val merchantBaseUrl = call.argument<String>("merchant_base_url")
                val snapToken = call.argument<String>("snap_token")

                val arguments = HashMap<String, Any>()
                arguments["client_key"] = clientKey as Any
                arguments["merchant_base_url"] = merchantBaseUrl as Any
                arguments["snap_token"] = snapToken as Any

                payWithToken(arguments, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun payWithToken(options: Map<String, Any>, result: Result) {
      val clientKey = options["client_key"] as? String ?: ""
      val merchantBaseUrl = options["merchant_base_url"] as? String ?: ""
      initSdk(result, clientKey, merchantBaseUrl)

      val snapToken = options["snap_token"] as? String ?: ""

      val setting = MidtransSDK.getInstance().uiKitCustomSetting
      setting.isSkipCustomerDetailsPages = true
      MidtransSDK.getInstance().uiKitCustomSetting = setting

      MidtransSDK.getInstance().startPaymentUiFlow(activity, snapToken);
    }

    private fun pay(options: Map<String, Any>, result: Result) {
        val clientKey = options["client_key"] as? String ?: ""
        val merchantBaseUrl = options["merchant_base_url"] as? String ?: ""
        initSdk(result, clientKey, merchantBaseUrl)

        val orderId = options["order_id"] as? String ?: ""
        val totalPrice = options["total_price"] as? Double ?: 0.0
        val selectedPaymentMethod = options["selected_payment_method"] as? Int ?: -1
        val transactionRequest = TransactionRequest(orderId, totalPrice)

        MidtransSDK.getInstance().transactionRequest = transactionRequest

        val setting = MidtransSDK.getInstance().uiKitCustomSetting
        setting.isSkipCustomerDetailsPages = true
        MidtransSDK.getInstance().uiKitCustomSetting = setting

        if(selectedPaymentMethod == -1) {
          MidtransSDK.getInstance().startPaymentUiFlow(activity)
        } else {
          MidtransSDK.getInstance().startPaymentUiFlow(activity, PaymentMethod.values()[selectedPaymentMethod])
        }
    }

    private fun initSdk(resultCallback: Result, clientKey: String, merchantBaseUrl: String) {
        SdkUIFlowBuilder.init()
                .setClientKey(clientKey) // client_key is mandatory
                .setContext(activity) // context is mandatory
                .setTransactionFinishedCallback {
                  if(it.response != null) {
                    Log.d("flutter_midtrans", it.response.toString())
                  }

                  val result = HashMap<String, Any>()

                  result["is_transaction_canceled"] = it.isTransactionCanceled

                  if(it.source != null) {
                    result["source"] = it.source
                  }

                  if(it.status != null) {
                    result["status"] = it.status
                  }

                  if(it.statusMessage != null) {
                    result["status_message"] = it.statusMessage
                  }

                  if(it.isTransactionCanceled) {
                    resultCallback.error("transaction_canceled", "transaction_canceled", result)
                    return@setTransactionFinishedCallback
                  }

                  if(it.status == "success") {
                    resultCallback.success(result)
                  } else {
                    resultCallback.error(it.status, it.statusMessage, result)
                  }
                    // Handle finished transaction here.
                } // set transaction finish callback (sdk callback)
                .setMerchantBaseUrl(merchantBaseUrl) //set merchant url (required)
                .enableLog(true) // enable sdk log (optional) theme. it will replace theme on snap theme on MAP ( optional)
                .buildSDK()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
