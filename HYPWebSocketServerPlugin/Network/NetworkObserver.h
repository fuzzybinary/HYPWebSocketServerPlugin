//
//  NetworkInterceptor.h
//  HYPWebSocketServerPlugin
//
//  Created by Jeff Ward on 2/15/18.
//  Copyright © 2018 WillowTree, Inc. All rights reserved.
//

@import PocketSocket;

#import <Foundation/Foundation.h>

#import "NetworkSniffer.h"

@interface NetworkObserver : NSObject

+ (nonnull instancetype)sharedInstance;
+ (void)setEnabled:(BOOL)enabled;

- (void)addNetworkSniffer:(nonnull NetworkSniffer*)sniffer;
- (void)removeNetworkSnifferForSocket:(nonnull PSWebSocket*) socket;

@end
