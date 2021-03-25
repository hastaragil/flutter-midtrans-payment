# Midtrans Payment Gateway for Flutter

Flutter Midtrans Payment Plugin

> Please Read [Midtrans Documentation](https://docs.midtrans.com/) before use this library and make sure you are already has Midtrans account for accessing the dashboard.

## Android setup

**Only support AndroidX and compile targe minimum 28**

Add style to your android/app/src/main/res/values/styles.xml :
```
<style name="AppTheme" parent="Theme.AppCompat.Light.DarkActionBar">
    <item name="windowActionBar">false</item>
    <item name="windowNoTitle">true</item>
</style>
```
And full styles.xml will be like below :
```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             Flutter draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="AppTheme" parent="Theme.AppCompat.Light.DarkActionBar">
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
    </style>
</resources>
```
And add the style to you Android Manifest in your application tag :
```
android:theme="@style/AppTheme"
```
## IOS
No specific setup required

## Example usage

Make sure you are already prepare these variables.

- `YOUR_CLIENT_ID`: Midtrans CLIENT ID
- `YOUR_URL_BASE`: Your backend URL base API to process payment

Pay
```dart
import 'package:flutter_midtrans_payment/flutter_midtrans_payment.dart';
...

var midtransPayParam = MidtransPayParam();
midtransPayParam.clientKey = "=";
midtransPayParam.merchantBaseUrl = "";
midtransPayParam.totalPrice = 0;
midtransPayParam.orderId = "";
midtransPayParam.selectedPaymentMethod = MidtransPaymentMethod.SHOPEEPAY.index; //optional
var result = await FlutterMidtransPayment.pay(midtransPayParam);
```

Pay with token
```dart
import 'package:flutter_midtrans_payment/flutter_midtrans_payment.dart';
...


var midtransPayParam = MidtransPayWithTokenParam();
midtransPayParam.clientKey = "";
midtransPayParam.merchantBaseUrl = "";
midtransPayParam.snapToken = "";
var result = await FlutterMidtransPayment.payWithToken(midtransPayParam);
```
