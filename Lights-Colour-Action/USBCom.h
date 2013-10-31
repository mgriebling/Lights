//
//  USBCom.h
//  myCreate
//
//  Created by Mike Griebling on 27 Oct 2013.
//  Copyright (c) 2013 xnav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USBCom : NSObject

+ (NSArray *)getPortNames;

- (id)initWithPortName:(NSString *)portName;
- (void)closePort;
- (NSInteger)writeString:(NSString *)string;
- (NSInteger)writeBytes:(unsigned char *)bytes withSize:(NSInteger)size;
- (NSInteger)readBytes:(unsigned char *)bytes maxSize:(NSInteger)size;
- (NSString *)readStringWithTimeOut:(double)timeOut;

@end
