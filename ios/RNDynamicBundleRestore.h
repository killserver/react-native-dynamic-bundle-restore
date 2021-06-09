
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@class RNDynamicBundleRestore;

@protocol RNDynamicBundleRestoreDelegate <NSObject>

- (void)dynamicBundle:(RNDynamicBundleRestore *)dynamicBundle requestsReloadForBundleURL:(NSURL *)bundleURL;

@end

@interface RNDynamicBundleRestore : NSObject <RCTBridgeModule>

@property (weak) id<RNDynamicBundleRestoreDelegate> delegate;

+ (NSMutableDictionary *)loadRegistry;
+ (void)storeRegistry:(NSDictionary *)dict;
+ (NSURL *)resolveBundleURL;
+ (void)setDefaultBundleURL:(NSURL *)URL;

- (void)reloadBundle;
- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)path;
- (void)unregisterBundle:(NSString *)bundleId;
- (void)setActiveBundle:(NSString *)bundleId;
- (NSDictionary *)getBundles;
- (NSString *)getActiveBundle;

@end
  
