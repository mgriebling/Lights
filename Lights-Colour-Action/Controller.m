//
//  Controller.m
//  Lights → Colour → Action
//
//  Created by Mike Griebling on 5 Nov 2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "Controller.h"
#import "USBCom.h"

@implementation Controller {
    USBCom *port;
    NSString *address;
    double timeOut;
}

#define READSCENES  @"10"
#define WRITESCENES @"20"
#define RUNSCENES   @"30"
#define ERASESCENES @"40"
#define CONFIGURE   @"50"
#define REPORT      @"60"
#define READMACROS  @"70"
#define WRITEMACROS @"80"
#define DISPLAY     @"90"

- (id)init {
    self = [super init];
    if (self) {
        port = nil;
        address = @"FF";    // default/global address
        timeOut = 0.5;
    }
    return self;
}

- (void)dealloc {
    [port closePort];
    port = nil;
}

- (NSString *)sendMessage:(NSString *)messageType withData:(NSString *)data {
    if (port) {
        [port writeString:[NSString stringWithFormat:@":%@%@%@00\r\n", address, messageType, data]];
        NSString *reply = [port readStringWithTimeOut:timeOut];
        return reply;
    }
    return @"";
}

- (BOOL)connectToPort:(NSString *)portName withBaudRate:(NSString *)baudRate {
    speed_t rate;
    if ([baudRate isEqualToString:@"9600"]) rate = B9600;
    else if ([baudRate isEqualToString:@"19200"]) rate = B19200;
    else if ([baudRate isEqualToString:@"38400"]) rate = B38400;
    else rate = B9600;
    port = [[USBCom alloc]initWithPortName:portName andBaudRate:rate];
    return (port != nil);
}

- (NSArray *)readScenesFromSceneAddress:(NSInteger)sceneAddress withLength:(NSInteger)length {
    NSString *dataString = [NSString stringWithFormat:@"%4lX%4lX", (long)sceneAddress, (long)length];
    NSString *reply = [self sendMessage:READSCENES withData:dataString];
    
    // decode scenes from reply
    // TBD
    return nil;
}

- (BOOL)writeScenes:(NSArray *)scenes toSceneAddress:(NSInteger)sceneAddress {
    return NO;
}

- (NSArray *)readMacrosFromMacroAddress:(NSInteger)macroAddress withLength:(NSInteger)length {
    return nil;
}

- (BOOL)writeMacros:(NSArray *)macros toMacroAddress:(NSInteger)macroAddress {
    return NO;
}

- (NSDictionary *)readSettings {
    return nil;
}

- (BOOL)writeSettings:(NSDictionary *)settings {
    return NO;
}

- (BOOL)setColourWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue white:(NSInteger)white {
    return NO;
}

@end
