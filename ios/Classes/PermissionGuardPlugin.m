#import <Flutter/Flutter.h>
#import "permission_guard-Swift.h"

@interface PermissionGuardPlugin : NSObject<FlutterPlugin>
@end

@implementation PermissionGuardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPermissionGuardPlugin registerWithRegistrar:registrar];
}
@end
