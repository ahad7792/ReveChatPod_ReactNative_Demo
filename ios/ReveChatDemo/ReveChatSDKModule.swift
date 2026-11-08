//
//  ReveChatSDKModule.swift
//  ReveChatDemo
//
//  Native bridge that lets JavaScript open the ReveChat UI.
//

import Foundation
import React
import ReveChatSDK
import UIKit

@objc(ReveChatSDKModule)
class ReveChatSDKModule: NSObject {

  /// Must outlive the call: the SDK keeps using this object while the chat is open.
  private let reveChatManager = ReveChatManager()

  /// React Native calls this on the main queue (see -requiresMainQueueSetup).
  @objc
  func startChat(_ accountId: String,
                 userName: String,
                 userEmail: String,
                 phone: String,
                 resolver resolve: @escaping RCTPromiseResolveBlock,
                 rejecter reject: @escaping RCTPromiseRejectBlock) {

    // React Native invokes TurboModule methods on its own serial queue, not the
    // main thread. Everything below touches UIKit, so hop to main first --
    // otherwise UIApplication.connectedScenes trips a main-thread assertion.
    // (requiresMainQueueSetup only governs module *initialisation*.)
    DispatchQueue.main.async {
      guard let presenter = Self.topViewController() else {
        reject("NO_PRESENTER", "Could not find a view controller to present the chat from", nil)
        return
      }

      self.reveChatManager.setupAccount(with: accountId)

      // React Native's root view controller is not a UINavigationController, so
      // present modally rather than pushing. The SDK provides this variant for
      // exactly this case. Swift imports the Objective-C selector
      // -initiateReveChatWith:visitorEmail:visitorMobile:onViewController: with
      // the last label shortened to `on:`.
      self.reveChatManager.initiateReveChat(with: userName,
                                            visitorEmail: userEmail,
                                            visitorMobile: phone,
                                            on: presenter)
      resolve("success")
    }
  }

  /// Walks past anything already presented so the chat is not pushed under a modal.
  private static func topViewController() -> UIViewController? {
    let scene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
      ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first

    guard var top = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
            ?? scene?.windows.first?.rootViewController else {
      return nil
    }
    while let presented = top.presentedViewController {
      top = presented
    }
    return top
  }

  /// The SDK touches UIKit during setup, so initialise on the main thread.
  @objc
  static func requiresMainQueueSetup() -> Bool {
    true
  }
}
