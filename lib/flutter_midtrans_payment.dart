
import 'dart:async';

import 'package:flutter/services.dart';

class MidtransPayParam {
  String merchantBaseUrl;
  String clientKey;
  String orderId;
  double totalPrice;
  int selectedPaymentMethod;
}

class MidtransPayWithTokenParam {
  String merchantBaseUrl;
  String clientKey;
  String snapToken;
}

enum MidtransPaymentMethod {
  CREDIT_CARD,
  BANK_TRANSFER,
  BANK_TRANSFER_BCA,
  BANK_TRANSFER_MANDIRI,
  BANK_TRANSFER_PERMATA,
  BANK_TRANSFER_BNI,
  BANK_TRANSFER_OTHER,
  GO_PAY,
  BCA_KLIKPAY,
  KLIKBCA,
  MANDIRI_CLICKPAY,
  MANDIRI_ECASH,
  EPAY_BRI,
  CIMB_CLICKS,
  INDOMARET,
  KIOSON,
  GIFT_CARD_INDONESIA,
  INDOSAT_DOMPETKU,
  TELKOMSEL_CASH,
  XL_TUNAI,
  DANAMON_ONLINE,
  AKULAKU,
  ALFAMART,
  SHOPEEPAY
}

class FlutterMidtransPayment {
  static const MethodChannel _channel =
      const MethodChannel('flutter_midtrans_payment');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> pay(MidtransPayParam midtransPayParam) async {
    final dynamic result = await _channel.invokeMethod('pay', <String, dynamic>{
      'client_key': midtransPayParam.clientKey,
      'merchant_base_url': midtransPayParam.merchantBaseUrl,
      'order_id': midtransPayParam.orderId,
      'total_price': midtransPayParam.totalPrice,
      'selected_payment_method': midtransPayParam.selectedPaymentMethod,
    });
    return result;
  }

  static Future<dynamic> payWithToken(MidtransPayWithTokenParam midtransPayWithTokenParam) async {
    final dynamic result = await _channel.invokeMethod('payWithToken', <String, dynamic>{
      'client_key': midtransPayWithTokenParam.clientKey,
      'merchant_base_url': midtransPayWithTokenParam.merchantBaseUrl,
      'snap_token': midtransPayWithTokenParam.snapToken,
    });
    return result;
  }
}
