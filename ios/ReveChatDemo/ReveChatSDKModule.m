//
//  ReveChatSDKModule.m
//  ReveChatDemo
//
//  Exports the Swift module to React Native. A Swift native module still needs
//  this Objective-C interface block for RN to discover it.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE (ReveChatSDKModule, NSObject)

RCT_EXTERN_METHOD(startChat:(NSString *)accountId
                  userName:(NSString *)userName
                  userEmail:(NSString *)userEmail
                  phone:(NSString *)phone
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
