
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

## Install for Android
add to file "MainActivity.java":

```
import android.os.Bundle;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import org.killserver.reactnativedynamicbundle.RNDynamicBundleModule;
```

replace:

```
public  class  MainActivity  extends  ReactActivity {
```

on:

```
public class MainActivity extends ReactActivity implements RNDynamicBundleModule.OnReloadRequestedListener {
```

and after this line:

```
  private RNDynamicBundleModule module;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(null);

    MainApplication app = (MainApplication)this.getApplicationContext();
      app.getReactNativeHost().getReactInstanceManager().addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
      @Override
      public void onReactContextInitialized(ReactContext context) {
        MainActivity.this.module = context.getNativeModule(RNDynamicBundleModule.class);
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

in "MainApplication.java" add:

```
import org.killserver.reactnativedynamicbundle.RNDynamicBundleModule;
import org.killserver.reactnativedynamicbundle.RNDynamicBundlePackage;
import javax.annotation.Nullable;
```

and replace:

```
new  ReactNativeHost(this) {
```

on:

```
new ReactNativeHost(this) {
        @Nullable
        @Override
        protected String getJSBundleFile() {
          return RNDynamicBundleModule.launchResolveBundlePath(MainApplication.this);
        }
```

## To do's
* Explanations of how to set it up on the native side. In the meanwhile have
  a look at AppDelegate.m for iOS.


## Getting started

`$ npm install react-native-dynamic-bundle-restore --save`

or

`$ yarn add react-native-dynamic-bundle-restore`


### Mostly automatic installation

`$ react-native link react-native-dynamic-bundle-restore`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-dynamic-bundle-restore` and add `RNDynamicBundle.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNDynamicBundle.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import org.killserver.reactnativedynamicbundle.RNDynamicBundlePackage;` to the imports at the top of the file
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
```
