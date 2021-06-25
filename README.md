
# react-native-dynamic-bundle-restore

### fork: https://github.com/mauritsd/react-native-dynamic-bundle

## What is this?

react-native-dynamic-bundle-restore is a library, similar to react-native-auto-updater
and CodePush, that allows you to change the React Native bundle loaded by
an application without updating the application itself (i.e. through the App
Store or Google Play). You could use this functionality to, for example:
* Get app updates to users quicker.
* Make A/B-testing or gradual rollouts as easy as on the web.

react-native-dynamic-bundle-restore differs from react-native-auto-updater and
alternatives in that it does not attempt to be a complete solution, only
providing the bare necessities for switching bundles and reloading the app. This
requires you to implement the logic to download and keep track of the bundles
yourself, but does give you complete freedom in how you implement your updater
or A/B testing logic.

### work with reanimated 2

## Install for Android

for version up to: 0.7.1
replace in file "MainApplication.java":
```
return RNDynamicBundleRestoreModule.launchResolveBundlePath(MainApplication.this);
```
to:
```java
return RNDynamicBundleRestoreModule.launchResolveBundlePath(MainApplication.this, BuildConfig.VERSION_NAME);
```

<details>
  <summary>add to file "MainActivity.java":</summary>
<p>

```java
import android.os.Bundle;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import org.killserver.reactnativedynamicbundlerestore.RNDynamicBundleRestoreModule;
```

replace:

```java
public  class  MainActivity  extends  ReactActivity {
```

on:

```java
public class MainActivity extends ReactActivity implements RNDynamicBundleRestoreModule.OnReloadRequestedListener {
```

and after this line:

```java
  private RNDynamicBundleRestoreModule module;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(null);

    MainApplication app = (MainApplication)this.getApplicationContext();
      app.getReactNativeHost().getReactInstanceManager().addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
      @Override
      public void onReactContextInitialized(ReactContext context) {
        MainActivity.this.module = context.getNativeModule(RNDynamicBundleRestoreModule.class);
        module.setListener(MainActivity.this);
      }
    });
  }

  @Override
  protected void onStart() {
    super.onStart();

    if (module != null) {
      module.setListener(this);
    }
  }

  @Override
  public void onReloadRequested() {
    this.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        MainActivity.this.getReactNativeHost().clear();
        MainActivity.this.recreate();
      }
    });
  }
```

</p>
</details>

<details>
  <summary>in "MainApplication.java" add:</summary>
<p>

```java
import org.killserver.reactnativedynamicbundlerestore.RNDynamicBundleRestoreModule;
import org.killserver.reactnativedynamicbundlerestore.RNDynamicBundleRestorePackage;
import javax.annotation.Nullable;
```

and replace:

```java
new  ReactNativeHost(this) {
```

on:

```java
new ReactNativeHost(this) {
        @Nullable
        @Override
        protected String getJSBundleFile() {
          return RNDynamicBundleRestoreModule.launchResolveBundlePath(MainApplication.this, BuildConfig.VERSION_NAME);
        }
```

</p>
</details>

## Install for IOS
<details>
  <summary>AppDelegate.h:</summary>
<p>

  add:
  ```objective-c
   #import  <RNDynamicBundleRestore.h>
   
   @class RCTRootView;
  ```
  after:
  ```objective-c
   #import  <UIKit/UIKit.h>
  ```
  
  replace:
  ```objective-c
   @interface  AppDelegate : UIResponder <UIApplicationDelegate, RCTBridgeDelegate>
  ```
  to:
  ```objective-c
  @interface  AppDelegate : UIResponder <UIApplicationDelegate, RNDynamicBundleRestoreDelegate>
  ```
  
  replace:
  ```objective-c
  @property (nonatomic, strong) UIWindow *window;
  ```
  to:
  ```objective-c
  @property (nonatomic, strong) UIWindow *window;
  
  @property (nonatomic, strong) NSDictionary *launchOptions;
  ```
  
</p>
</details>
<details>
  <summary>AppDelegate.m:</summary>
<p>

replace:
  ```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"YOU_VERY_COOL_APPLICATION"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}
  ```
  to:
  ```objective-c
- (void)getRootViewForBundleURL {
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:self.launchOptions];
  RNDynamicBundleRestore *dynamicBundle = [bridge moduleForClass:[RNDynamicBundleRestore class]];
  dynamicBundle.delegate = self;
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"YOU_VERY_COOL_APPLICATION"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
}
- (void)dynamicBundle:(RNDynamicBundleRestore *)dynamicBundle requestsReloadForBundleURL:(NSURL *)bundleURL
{
  [self getRootViewForBundleURL];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
  InitializeFlipper(application);
#endif
  
  self.launchOptions = launchOptions;
  
  [self getRootViewForBundleURL];
  return YES;
}
  ```
  
  replace:
  ```objective-c
  - (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  ```
  to:
  ```objective-c
  - (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  NSURL *bundle = [RNDynamicBundleRestore resolveBundleURL];
  if(bundle!=nil) {
    return bundle;
  }
  ```
  
</p>
</details>


## Getting started

`$ npm install react-native-dynamic-bundle-restore --save`

or

`$ yarn add react-native-dynamic-bundle-restore`


### Mostly automatic installation

`$ react-native link react-native-dynamic-bundle-restore`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-dynamic-bundle-restore` and add `RNDynamicBundleRestore.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNDynamicBundleRestore.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import org.killserver.reactnativedynamicbundlerestore.RNDynamicBundleRestorePackage;` to the imports at the top of the file
  - Add `new RNDynamicBundlePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
```
include ':react-native-dynamic-bundle-restore'
project(':react-native-dynamic-bundle-restore').projectDir = new File(rootProject.projectDir,   '../node_modules/react-native-dynamic-bundle-restore/android')
```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
```
implementation project(':react-native-dynamic-bundle-restore')
```


## Usage
```javascript
import {
  setActiveBundle,
  registerBundle,
  unregisterBundle,
  reloadBundle
} from 'react-native-dynamic-bundle-restore';

/* Register a bundle in the documents directory of the app. This could be
 * pre-packaged in your app, downloaded over http, etc. Paths are relative
 * to your documents directory.
 */
registerBundle('a_b_test', 'bundles/a_b_test.bundle');

/* Set the active bundle to a_b_test. This means that on the next load
 * this bundle will be loaded instead of the default.
 */
setActiveBundle('a_b_test');

/* Unregister a bundle once you're done with it. Note that you will have to
 * remove the file yourself.
 */
unregisterBundle('a_b_test');

/* In some circumstances (e.g. the user consents to an update) we want to
 * force a bundle reload instead of waiting until the next app restart.
 * Note that this will have to result in the destruction of the current
 * RCTBridge and its recreation with the new bundle URL. It is therefore
 * recommended to sync data and let actions complete before calling this.
 */
reloadBundle();

/*
 * clear all store about bundles(need for moving between versions)
 */
resetAllBundlesBetweenVersion();
```
