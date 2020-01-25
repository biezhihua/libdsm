#import "DsmPlugin.h"
#if __has_include(<libdsm/libdsm-Swift.h>)
#import <libdsm/libdsm-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "libdsm-Swift.h"
#endif

@implementation DsmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDsmPlugin registerWithRegistrar:registrar];
}
@end
