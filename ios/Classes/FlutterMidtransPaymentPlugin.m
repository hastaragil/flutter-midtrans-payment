#import "FlutterMidtransPaymentPlugin.h"
#if __has_include(<flutter_midtrans_payment/flutter_midtrans_payment-Swift.h>)
#import <flutter_midtrans_payment/flutter_midtrans_payment-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_midtrans_payment-Swift.h"
#endif

@implementation FlutterMidtransPaymentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMidtransPaymentPlugin registerWithRegistrar:registrar];
}
@end
