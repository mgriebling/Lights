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

- (NSArray *)readScenesFromEEPROMAddress:(NSInteger)address withLength:(NSInteger)length {
    return nil;
}

- (BOOL)writeScenes:(NSArray *)scenes toEEPROMAddress:(NSInteger)address {
    return NO;
}

- (NSArray *)readMacrosFromEEPROMAddress:(NSInteger)address withLength:(NSInteger)length {
    return nil;
}

- (BOOL)writeMacros:(NSArray *)macros toEEPROMAddress:(NSInteger)address {
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
