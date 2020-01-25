#import "LibdsmFlutterPlugin.h"
#if __has_include(<libdsm_flutter/libdsm_flutter-Swift.h>)
#import <libdsm_flutter/libdsm_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "libdsm_flutter-Swift.h"
#endif

@implementation LibdsmFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLibdsmFlutterPlugin registerWithRegistrar:registrar];
}
@end
