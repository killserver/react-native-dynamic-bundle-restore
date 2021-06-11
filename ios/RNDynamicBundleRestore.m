
#import "RNDynamicBundleRestore.h"

static NSString * const nameBundleList = @"bundleList";

static NSString * const kBundleRegistryStoreFilename = @"_RNDynamicBundleRestores.plist";

@implementation RNDynamicBundleRestore

static NSURL *_defaultBundleURL = nil;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (NSString *) getBuildId {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getNameBundle {
    NSString *buildId = [RNDynamicBundleRestore getBuildId];
    NSString *name = [NSString stringWithFormat: @"%@%@", buildId, @"-activeBundles"];
    return name;
}

+ (NSMutableDictionary *)createEmptyRegistry {

    NSString *name = [RNDynamicBundleRestore getNameBundle];
//        NSDictionary *defaults = @{
//            @"bundleList": [NSMutableDictionary dictionary]
//        };
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    defaults[nameBundleList] = [NSMutableDictionary dictionary];
    defaults[name] = @"";
    //[defaults setValue:@"" forUndefinedKey:name];
    return [defaults mutableCopy];
}

+ (NSMutableDictionary *)loadRegistry
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kBundleRegistryStoreFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return [RNDynamicBundleRestore createEmptyRegistry];
    } else {
        return [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
}

- (bool)resetAllBundlesBetweenVersion {
    NSMutableDictionary *dict = [RNDynamicBundleRestore createEmptyRegistry];
    [RNDynamicBundleRestore storeRegistry:dict];
    return true;
}

+ (void)storeRegistry:(NSDictionary *)dict
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kBundleRegistryStoreFilename];
    
    [dict writeToFile:path atomically:YES];
}

+ (NSURL *)resolveBundleURL
{
    NSMutableDictionary *dict = [RNDynamicBundleRestore loadRegistry];
    NSString *name = [RNDynamicBundleRestore getNameBundle];
    NSString *activeBundles = dict[name]==nil ? @"" : dict[name];
    if ([activeBundles isEqualToString:@""]) {
        return _defaultBundleURL;
    }
    NSString *bundleRelativePath = dict[nameBundleList][activeBundles];
    if (bundleRelativePath == nil) {
        return _defaultBundleURL;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:bundleRelativePath];
    
    return [NSURL fileURLWithPath:path];
}

+ (void)setDefaultBundleURL:(NSURL *)URL
{
    _defaultBundleURL = URL;
}

- (void)reloadBundle
{
    [self.delegate dynamicBundle:self
      requestsReloadForBundleURL:[RNDynamicBundleRestore resolveBundleURL]];
}

- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)relativePath
{
    NSMutableDictionary *dict = [RNDynamicBundleRestore loadRegistry];
    dict[nameBundleList][bundleId] = relativePath;
    [RNDynamicBundleRestore storeRegistry:dict];
}

- (void)unregisterBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNDynamicBundleRestore loadRegistry];
    NSMutableDictionary *bundlesDict = dict[nameBundleList];
    [bundlesDict removeObjectForKey:bundleId];
    [RNDynamicBundleRestore storeRegistry:dict];
}

- (void)setActiveBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNDynamicBundleRestore loadRegistry];
    NSString *name = [RNDynamicBundleRestore getNameBundle];
    //dict[name] = bundleId == nil ? @"" : bundleId;
    [dict setValue:bundleId == nil ? @"" : bundleId forKey:name];
    [RNDynamicBundleRestore storeRegistry:dict];
}

- (NSDictionary *)getBundles
{
    NSMutableDictionary *bundleList = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [RNDynamicBundleRestore loadRegistry];
    for (NSString *bundleId in dict[nameBundleList]) {
        NSString *relativePath = dict[bundleId];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:relativePath];
        NSURL *URL = [NSURL fileURLWithPath:path];
        
        bundleList[bundleId] = [URL absoluteString];
    }
    
    return bundleList;
}

- (NSString *)getActiveBundle
{
    NSMutableDictionary *dict = [RNDynamicBundleRestore loadRegistry];
    NSString *name = [RNDynamicBundleRestore getNameBundle];
    NSString *activeBundles = dict[name]!=nil ? dict[name] : @"";
    if ([activeBundles isEqualToString:@""]) {
        return nil;
    }
    
    return activeBundles;
}

/* Make wrappers for everything that is exported to the JS side. We want this
 * because we want to call some of the methods in this module from the native side
 * as well, which requires us to put them into the header file. Since RCT_EXPORT_METHOD
 * is largely a black box it would become rather brittle and unpredictable which method
 * definitions exactly to put in the header.
 */
RCT_REMAP_METHOD(reloadBundle, exportedReloadBundle)
{
    [self reloadBundle];
}

RCT_REMAP_METHOD(registerBundle, exportedRegisterBundle:(NSString *)bundleId atRelativePath:(NSString *)path)
{
    [self registerBundle:bundleId atRelativePath:path];
}

RCT_REMAP_METHOD(unregisterBundle, exportedUnregisterBundle:(NSString *)bundleId)
{
    [self unregisterBundle:bundleId];
}

RCT_REMAP_METHOD(setActiveBundle, exportedSetActiveBundle:(NSString *)bundleId)
{
    [self setActiveBundle:bundleId];
}

RCT_REMAP_METHOD(resetAllBundlesBetweenVersion,
                 exportedresetAllBundlesBetweenVersionWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    bool completed = [self resetAllBundlesBetweenVersion];
    resolve(@(completed));
}

RCT_REMAP_METHOD(getBundles,
                 exportedGetBundlesWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([self getBundles]);
}

RCT_REMAP_METHOD(getActiveBundle,
                 exportedGetActiveBundleWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *activeBundles = [self getActiveBundle];
    if (activeBundles == nil) {
        resolve([NSNull null]);
    } else {
        resolve(activeBundles);
    }
}

RCT_EXPORT_MODULE()

@end
  
