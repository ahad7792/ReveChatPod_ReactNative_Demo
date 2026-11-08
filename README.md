# ReveChatPod_ReactNative_Demo

Minimal React Native app integrating the **ReveChat iOS SDK** via CocoaPods
(`pod 'ReveChatSDK', '3.0.2.10'`).

Built to verify the integration steps on
<https://www.revechat.com/help-center/react-native-ios-sdk/>, which predate the
React Native 0.77 Swift app-delegate template.

Verified on React Native 0.88.1, Xcode 27.2, CocoaPods 1.16.2, physical device.

## Run it

```sh
npm install
cd ios && pod install && cd ..   # first run is slow: RN builds from source
npm start                        # Metro
```

Then open `ios/ReveChatDemo.xcworkspace` in Xcode, pick a **physical device**
(the SDK framework is device-only arm64, with no Simulator slice) and Run.

Set your own account id in [`App.tsx`](App.tsx):

```ts
const ACCOUNT_ID = '2552651';
```

## What the integration consists of

| File | Purpose |
| --- | --- |
| [`ios/Podfile`](ios/Podfile) | the pod, `use_frameworks! :linkage => :dynamic`, and three required hooks |
| [`ios/ReveChatDemo/ReveChatSDKModule.swift`](ios/ReveChatDemo/ReveChatSDKModule.swift) | native module that presents the chat UI |
| [`ios/ReveChatDemo/ReveChatSDKModule.m`](ios/ReveChatDemo/ReveChatSDKModule.m) | `RCT_EXTERN_MODULE` block exposing it to JavaScript |
| [`ios/ReveChatDemo/Info.plist`](ios/ReveChatDemo/Info.plist) | camera, photo library and microphone usage descriptions |
| [`App.tsx`](App.tsx) | one `NativeModules.ReveChatSDKModule.startChat(...)` call |

Both native files must be added to the app target in Xcode; creating them on
disk is not enough.

## Things the published guide does not cover

1. **`ENV['RCT_USE_RN_DEP'] = '0'` / `ENV['RCT_USE_PREBUILT_RNCORE'] = '0'`** at
   the top of the Podfile. React Native 0.77+ ships its own SocketRocket inside
   the prebuilt `ReactNativeDependencies.framework` and resolves the
   `SocketRocket` pod to a facade that builds no standalone framework.
   `ReveChatSDK.framework` links `@rpath/SocketRocket.framework/SocketRocket`,
   which then never gets embedded, and the app dies at launch with
   `dyld: Library not loaded`. Building RN's dependencies from source produces a
   real `SocketRocket.framework` that CocoaPods embeds.
2. **Deployment-target `post_install` hook.** Xcode 27 rejects any target below
   iOS 15.0 outright, where Xcode 26 only warned.
3. **AFNetworking `netinet6/in6.h` `post_install` hook.** Xcode 26+ declares
   that header private; AFNetworking 4.0.1 imports it. Pod sources install
   `0444`, so the hook does a chmod round-trip.
4. **`DispatchQueue.main.async` in the native module.** React Native invokes
   module methods on its own serial queue; `UIApplication.connectedScenes` traps
   off the main thread. `requiresMainQueueSetup` only governs module
   *initialisation*.
5. **No `AppDelegate.h` / `AppDelegate.m`**, and no `UINavigationController` to
   push onto — the guide's Steps 3, 4 and 8 do not apply. The module presents
   the chat modally instead.
6. **The guide's `pre_install` hook breaks the build** on 0.77+ and is left out
   entirely.
