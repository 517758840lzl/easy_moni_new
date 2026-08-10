#import "GoogleMlKitFaceDetectionPlugin.h"

@implementation GoogleMlKitFaceDetectionPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  // No-op: iOS face liveness uses Apple Vision, not ML Kit.
}

@end
