//
//  NetworkSniffer.h
//  HYPWebSocketServerPlugin
//
//  Created by Jeff Ward on 2/19/18.
//  Copyright © 2018 WillowTree, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PocketSocket;

@interface NetworkSniffer : NSObject

@property(nonatomic, readonly, nonnull) PSWebSocket* socket;

-(nullable instancetype)initWithSocket:(PSWebSocket*_Nonnull) socket;

/// Call when app is about to send HTTP request.
- (void)requestWillBeSentWithRequestID:(NSString *_Nonnull)requestID request:(NSURLRequest *_Nonnull)request redirectResponse:(NSURLResponse *_Nullable)redirectResponse;

/// Call when HTTP response is available.
- (void)responseReceivedWithRequestID:(NSString*_Nonnull)requestID response:(NSURLResponse *_Nullable)response;

/// Call when HTTP request has finished loading.
- (void)loadingFinishedWithRequestID:(NSString *_Nonnull)requestID response:(NSURLResponse*_Nullable)response responseBody:(NSData *_Nonnull)responseBody;

/// Call when HTTP request has failed to load.
- (void)loadingFailedWithRequestID:(NSString *_Nonnull)requestID response:(NSURLResponse*_Nullable)response error:(NSError *_Nonnull)error;

@end
