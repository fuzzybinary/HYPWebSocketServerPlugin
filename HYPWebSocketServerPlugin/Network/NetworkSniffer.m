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
    // Ignore until the request is complete (or canceled)
}

- (void)loadingFinishedWithRequestID:(NSString *)requestID response:(NSURLResponse*)response responseBody:(NSData *)responseBody
{
    NSString* strData = [responseBody base64EncodedStringWithOptions:0];
    NSHTTPURLResponse* httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse*)response : nil;
    NSDictionary* data = @{@"type": @"response_body",
                           @"request_id": requestID,
                           @"status_code": (httpResponse != nil ? @([httpResponse statusCode]) : [NSNull null]),
                           @"body": strData
                           };
    HYPWebSocketMessage* message = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_response" data:data];
    [self.socket send:[message asJson]];
}

- (void)loadingFailedWithRequestID:(NSString *)requestID response:(NSURLResponse*)response error:(NSError *)error
{
    NSHTTPURLResponse* httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse*)response : nil;
    NSDictionary* data = @{@"type": @"response_error",
                           @"request_id": requestID,
                           @"status_code": (httpResponse != nil ? @([httpResponse statusCode]) : [NSNull null]),
                           @"error": [error localizedDescription]};
    HYPWebSocketMessage* message = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_response" data:data];
    [self.socket send:[message asJson]];
}

@end
