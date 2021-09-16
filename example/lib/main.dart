import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_midtrans_payment/flutter_midtrans_payment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    log("mulai");
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterMidtransPayment.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                  child: Text('Pay'),
                  onPressed: () async {
                    var midtransPayParam = MidtransPayParam();
                    midtransPayParam.clientKey = "=";
                    midtransPayParam.merchantBaseUrl = "";
                    midtransPayParam.totalPrice = 0;
                    midtransPayParam.orderId = "";
                    midtransPayParam.selectedPaymentMethod =
                        MidtransPaymentMethod.SHOPEEPAY.index;
                    var result =
                        await FlutterMidtransPayment.pay(midtransPayParam);
                    log(result);
                  }),
              ElevatedButton(
                  child: Text('Pay with token2'),
                  onPressed: () async {
                    log("start");
                    var midtransPayParam = MidtransPayWithTokenParam();
                    midtransPayParam.clientKey =
                        "SB-Mid-client-lqSYrzuU0C8KghnG";
                    midtransPayParam.merchantBaseUrl =
                        "https://kesan-api.bangun-kreatif.com";
                    midtransPayParam.snapToken =
                        "3143c741-3e24-4251-96e5-e5391cd19280";
                    try {
                      var result = await FlutterMidtransPayment.payWithToken(
                          midtransPayParam);
                      log('result');
                      log(result.toString());
                    } catch (err) {

                      log(err.toString());
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
