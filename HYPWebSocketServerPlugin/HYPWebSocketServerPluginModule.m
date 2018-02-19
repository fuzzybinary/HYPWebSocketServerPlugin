//  Copyright (c) 2017 WillowTree, Inc.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HYPWebSocketServerPluginModule.h"

@import HyperionCore;

@import PocketSocket;

#import "NetworkObserver.h"
#import "NetworkSniffer.h"

@interface HYPWebSocketServerPluginModule () <HYPPluginMenuItemDelegate, PSWebSocketServerDelegate>

@property(strong, nonatomic) PSWebSocketServer* server;
@property(strong, nonatomic) NSMutableSet<PSWebSocket*>* openSockets;

@property(strong, nonatomic) NSMutableDictionary<NSString*, HYPSocketMessageHandler>* messageHandlers;

@end

@implementation HYPWebSocketServerPluginModule
@synthesize pluginMenuItem = _pluginMenuItem;

- (instancetype)initWithExtension:(nonnull id<HYPPluginExtension>)extension
{
    if(self = [super initWithExtension:extension])
    {
        self.openSockets = [[NSMutableSet alloc] init];
        self.messageHandlers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addMessage:(NSString *)messageName handler:(HYPSocketMessageHandler)handler
{
    [self.messageHandlers setObject:[handler copy] forKey:messageName];
}

- (void)sendMessage:(HYPWebSocketMessage *)message
{
    NSString* serialized = [message asJson];
    for(PSWebSocket* socket in self.openSockets)
    {
        [socket send:serialized];
    }
}

- (void)defaultMessageHandler:(HYPWebSocketMessage*)message fromSocket:(PSWebSocket*)socket;
{
    if([message.message isEqualToString:@"sniff"]) {
        if([[message.data valueForKey:@"enabled"] boolValue]) {
            NetworkSniffer* sniffer = [[NetworkSniffer alloc] initWithSocket:socket];
            [[NetworkObserver sharedInstance] addNetworkSniffer:sniffer];
        } else {
            [[NetworkObserver sharedInstance] removeNetworkSnifferForSocket:socket];
        }
        // Reply with ack
        HYPWebSocketMessage* ackMessage = [[HYPWebSocketMessage alloc] initWithMessage:@"sniff_sniff" data:message.data];
        [socket send:[ackMessage asJson]];
    } else {
        [self.delegate websocketPlugin:self didReceiveMessage:message];
    }
}

- (UIView*)pluginMenuItem
{
    if(_pluginMenuItem)
    {
        return _pluginMenuItem;
    }
    
    HYPPluginMenuItem *pluginItem = [[HYPPluginMenuItem alloc] init];
    pluginItem.delegate = self;
    [pluginItem bindWithTitle:[self pluginMenuItemTitle] image:[self pluginMenuItemImage]];
    
    _pluginMenuItem = pluginItem;
    
    return _pluginMenuItem;
}

- (NSString *)pluginMenuItemTitle
{
    return @"Web Socket Server";
}

- (UIImage *)pluginMenuItemImage
{
    return [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                             pathForResource:@"timer" ofType:@"png"]];
}

- (void)pluginMenuItemSelected:(UIView<HYPPluginMenuItem> *)pluginView
{
    if(self.server == nil)
    {
        self.server = [PSWebSocketServer serverWithHost:@"127.0.0.1" port:5163];
        self.server.delegate = self;
        [self.server start];
        [_pluginMenuItem setSelected:YES animated:YES];
        [NetworkObserver setEnabled:YES];
    }
    else
    {
        [self closeServer];
    }
}

- (void)closeServer
{
    [self.server stop];
    self.server = nil;
    [_pluginMenuItem setSelected:NO animated:YES];
    [NetworkObserver setEnabled:NO];
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server
{
    
}

- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error
{
    [self closeServer];
}

- (void)serverDidStop:(PSWebSocketServer *)server
{
    
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket
{
    [self.openSockets addObject:webSocket];
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message
{
    if([message isKindOfClass:[NSString class]])
    {
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if(error == nil && [dict objectForKey:@"message"] && [dict objectForKey:@"data"])
        {
            HYPWebSocketMessage* finalMessage = [[HYPWebSocketMessage alloc] initWithMessage:[dict objectForKey:@"message"] data:[dict objectForKey:@"data"]];
            HYPSocketMessageHandler handler = [self.messageHandlers objectForKey:finalMessage.message];
            if(handler != nil)
            {
                handler(self, finalMessage);
            }
            else
            {
                [self defaultMessageHandler:finalMessage fromSocket:webSocket];
            }
        }
    }
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self.openSockets removeObject:webSocket];
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [self.openSockets removeObject:webSocket];
}

@end
