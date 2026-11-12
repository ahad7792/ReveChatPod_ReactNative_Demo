# ReveChatPod_ReactNative_Demo

Minimal React Native app integrating the **ReveChat iOS SDK** via CocoaPods
(`pod 'ReveChatSDK', '3.1.0-stc-uat'`).

Used to verify the integration steps on
<https://www.revechat.com/help-center/react-native-ios-sdk/>. That page still
documents 3.0.2.10 and its workarounds, which are no longer needed. See
[Upgrading from 3.0.2.x](#upgrading-from-302x).

Verified on React Native 0.88.1, Xcode 27.2, CocoaPods 1.16.2, iOS Simulator.

## Run it

```sh
npm install
cd ios && pod install && cd ..
npm start                        # Metro
```

Then open `ios/ReveChatDemo.xcworkspace` in Xcode, pick a simulator or a
device, and Run. Or run `npx react-native run-ios` from the project root.

Set your own account id in [`App.tsx`](App.tsx):

```ts
const ACCOUNT_ID = '2088935';
```

### About `3.1.0-stc-uat`

This is a CocoaPods pre-release built for STC's UAT environment. The chat
socket, file upload/preview and avatars all point at `chatbot-uat.stc.com.kw`,
so use an account that exists on that server.

CocoaPods only installs a pre-release when the Podfile names it exactly. A
plain `pod 'ReveChatSDK'` or `'~> 3.0'` never picks it up. When the general
3.1.0 release is published, change the version line to `'3.1.0'`.

Audio and video calls in 3.1.0 have not been through QA on hardware yet.

## What the integration consists of

| File | Purpose |
| --- | --- |
| [`ios/Podfile`](ios/Podfile) | the pod, `use_frameworks! :linkage => :static`, and one deployment-target hook |
| [`ios/ReveChatDemo/ReveChatSDKModule.swift`](ios/ReveChatDemo/ReveChatSDKModule.swift) | native module that presents the chat UI |
| [`ios/ReveChatDemo/ReveChatSDKModule.m`](ios/ReveChatDemo/ReveChatSDKModule.m) | `RCT_EXTERN_MODULE` block exposing it to JavaScript |
| [`ios/ReveChatDemo/Info.plist`](ios/ReveChatDemo/Info.plist) | camera, photo library and microphone usage descriptions |
| [`App.tsx`](App.tsx) | one `NativeModules.ReveChatSDKModule.startChat(...)` call |

Both native files must be added to the app target in Xcode; creating them on
disk is not enough.

The Podfile needs no ReveChat-specific hooks or `ENV` flags. 3.1.0 ships as an
XCFramework (device + arm64/x86_64 simulator) whose only dependency is
`WebRTC-lib`, also a prebuilt XCFramework. CocoaPods embeds both as-is under
either linkage, so the app keeps static linkage and React Native's prebuilt
dependencies (fast builds).

No `NSAllowsArbitraryLoads` exception is needed: the SDK passes default App
Transport Security.

## Things the published guide does not cover

1. **Deployment-target `post_install` hook.** Xcode 27 rejects any target below
   iOS 15.0 outright, where Xcode 26 only warned. This is for React Native's
   own pods, not ReveChat; the SDK itself requires iOS 15.0.
2. **`DispatchQueue.main.async` in the native module.** React Native invokes
   module methods on its own serial queue; `UIApplication.connectedScenes` traps
   off the main thread. `requiresMainQueueSetup` only governs module
   *initialisation*.
3. **No `AppDelegate.h` / `AppDelegate.m`**, and no `UINavigationController` to
   push onto. The guide's Steps 3, 4 and 8 do not apply. The module presents
   the chat modally instead.

## Upgrading from 3.0.2.x

The 3.0.2.x integration needed several workarounds. Remove all of them:

| 3.0.2.x Podfile | 3.1.0 |
| --- | --- |
| `ENV['RCT_USE_RN_DEP'] = '0'` and `ENV['RCT_USE_PREBUILT_RNCORE'] = '0'` | Delete. They forced RN to build from source so a real `SocketRocket.framework` existed; the SDK no longer uses SocketRocket. |
| `use_frameworks! :linkage => :dynamic` | `:linkage => :static` (either works) |
| AFNetworking `netinet6/in6.h` `post_install` patch | Delete. AFNetworking is gone. |
| The guide's `pre_install` hook forcing ReveChat pods dynamic | Delete. It names pods that no longer exist. |
| "Run on a physical device" | The simulator works. |

Then do a clean install:

```sh
cd ios
rm -rf Pods build
pod install
```

## Troubleshooting

**Launch crash: `Symbol not found: __ZN8facebook6hermes3cdp11CDPDebugAPI...`**,
referenced from `React.framework`, expected in `hermesvm.framework`.

A Release build of Hermes is sitting in `ios/Pods/hermes-engine` while the
app builds Debug. React Native's "Replace Hermes" build phase swaps it in
place for Release builds and does not always swap it back. Not a ReveChat
issue. Fix:

```sh
cd ios
rm -rf Pods/hermes-engine
pod install
```
