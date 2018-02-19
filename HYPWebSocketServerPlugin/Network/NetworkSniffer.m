//
//  NetworkSniffer.m
//  HYPWebSocketServerPlugin
//
//  Created by Jeff Ward on 2/19/18.
//  Copyright © 2018 WillowTree, Inc. All rights reserved.
//

#import "NetworkSniffer.h"

#import "HYPWebSocketMessage.h"

@interface NetworkSniffer()

@property PSWebSocket* socket;

@end

@implementation NetworkSniffer

-(instancetype)initWithSocket:(PSWebSocket *)socket
{
    if(self = [super init]) {
        self.socket = socket;
    }
    
    return self;
}

-(void)requestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    NSDictionary* data = @{@"type": @"will_send",
                           @"request_id": requestID,
                           @"request_url": [request.URL absoluteString]
                           };
    HYPWebSocketMessage* message = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_response" data:data];
    [self.socket send:[message asJson]];
}

-(void)responseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDictionary* data = @{@"type": @"response",
                           @"request_id": requestID,
                           @"request_url": [response.URL absoluteString],
                           };
    HYPWebSocketMessage* message = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_response" data:data];
    [self.socket send:[message asJson]];
}

- (void)loadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSString* strData = [responseBody base64EncodedStringWithOptions:0];
    NSDictionary* data = @{@"type": @"response_body",
                           @"request_id": requestID,
                           @"body": strData
                           };
    HYPWebSocketMessage* message = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_response" data:data];
    [self.socket send:[message asJson]];
}

- (void)loadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    NSDictionary* data = @{@"type": @"response_error",
                           @"request_id": requestID,
                           @"error": [error localizedDescription]};
    HYPWebSocketMessage* message = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_response" data:data];
    [self.socket send:[message asJson]];
    
}

@end
