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

- (NSInteger)hexToInteger:(NSString *)hex {
    NSInteger number = 0;
    for (int i=0; i<hex.length; i++) {
        unichar digit = [hex characterAtIndex:i];
        if (digit >= '0' && digit <= '9') {
            number = number * 16 + digit - '0';
        } else if (digit >= 'A' && digit <= 'F') {
            number = number * 16 + digit - 'A' + 10;
        }
    }
    return number;
}

- (NSDictionary *)readSettings {
    NSString *reply = [self sendMessage:REPORT withData:@"FFFF"];
    
    // decode settings from reply
    if (reply.length > 0) {
        reply = [reply substringFromIndex:10];
        if (![reply hasPrefix:@"EF"]) {
            NSInteger nightSense = [[reply substringToIndex:1] intValue];
            reply = [reply substringFromIndex:2];
            NSInteger offTime = [self hexToInteger:[reply substringToIndex:1]];
            reply = [reply substringFromIndex:2];
            NSInteger onTime = [self hexToInteger:[reply substringToIndex:1]];
            reply = [reply substringFromIndex:2];
            NSInteger totalTime = [self hexToInteger:[reply substringToIndex:3]];
            reply = [reply substringFromIndex:4];
            NSInteger startSequence = [self hexToInteger:[reply substringToIndex:3]];
            reply = [reply substringFromIndex:4];
            NSInteger activeSequences = [self hexToInteger:[reply substringToIndex:3]];
            reply = [reply substringFromIndex:4];
            NSInteger deviceAddress = [self hexToInteger:[reply substringToIndex:1]];
            reply = [reply substringFromIndex:2];
            NSInteger totalSequences = [self hexToInteger:reply];
            NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:@(nightSense), @"nightsense",
                                      @(offTime), @"offtime", @(onTime), @"ontime", @(totalTime), @"totaltime",
                                      @(startSequence), @"startsequence", @(activeSequences), @"activesequences",
                                      @(deviceAddress), @"deviceaddress", @(totalSequences), @"totalsequences", nil];
            return settings;
        }
    }
    return nil;
}

- (BOOL)writeSettings:(NSDictionary *)settings {
    for (NSString *key in settings) {
        NSNumber *value = [settings objectForKey:key];
        NSInteger address = 0;
        NSString *reply = [self sendMessage:CONFIGURE withData:[NSString stringWithFormat:@"%4lX%4lX", address, value.integerValue]];
        if (reply.length == 0) return NO;
    }
    return YES;
}

- (BOOL)setColourWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue white:(NSInteger)white {
    NSString *dataString = [NSString stringWithFormat:@"%2lX%2lX%2lX%2lX", (long)red, (long)green, (long)blue, (long)white];
    NSString *reply = [self sendMessage:DISPLAY withData:dataString];
    return reply.length > 0;
}

@end
