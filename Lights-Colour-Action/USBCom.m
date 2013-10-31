//
//  USBCom.m
//  myCreate
//
//  Created by Mike Griebling on 27 Oct 2013.
//  Copyright (c) 2013 xnav. All rights reserved.
//

#import "USBCom.h"

#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <termios.h>

@implementation USBCom {
    int fd;
    struct termios oldtio, newtio;
}

+ (NSArray *)getPortNames {
	kern_return_t			kernResult;
    CFMutableDictionaryRef	classesToMatch;
	io_object_t             modemService;
	io_iterator_t           matchingServices;
    NSMutableArray *        ttySelect;
	
	ttySelect = [NSMutableArray array];
	
	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    if (classesToMatch == NULL) {
        NSLog(@"IOServiceMatching returned a NULL dictionary.");
    } else {
		CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
							 CFSTR(kIOSerialBSDRS232Type));
	}
	kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &matchingServices);
    if (KERN_SUCCESS != kernResult) {
        NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
    }
	while ((modemService = IOIteratorNext(matchingServices))){
		CFTypeRef bsdPathAsCFString = IORegistryEntryCreateCFProperty(modemService,
                                                            CFSTR(kIODialinDeviceKey),
                                                            kCFAllocatorDefault,
                                                            0);
        [ttySelect addObject:(__bridge id)(bsdPathAsCFString)];
	}
	(void) IOObjectRelease(modemService);
    return ttySelect;
}

- (id)initWithPortName:(NSString *)portName {
    self = [super init];
	BOOL retryOpen = YES;
	
	do {
		fd = open([portName cStringUsingEncoding:NSUTF8StringEncoding], O_RDWR | O_NOCTTY | O_NDELAY);
		if (fd < 0) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert addButtonWithTitle:@"Cancel"];
			[alert setMessageText:@"Try open again?"];
			[alert setInformativeText:[NSString stringWithUTF8String:strerror(errno)]];
			[alert setAlertStyle:NSWarningAlertStyle];
			
			if ([alert runModal] == NSAlertFirstButtonReturn) {
				// OK clicked, try open again
				retryOpen = YES;
			} else {
				retryOpen = NO;
			}
		} else {
			retryOpen = NO;
			tcgetattr(fd, &oldtio);
			bzero(&newtio, sizeof(newtio));
			newtio.c_cflag = CS8 | CLOCAL | CREAD;
			newtio.c_iflag = 0;
			newtio.c_oflag = 0;
			newtio.c_lflag = 0;
			newtio.c_ispeed = B9600;
			newtio.c_ospeed = B9600;
			tcsetattr(fd, TCSAFLUSH, &newtio);
		}
	} while (retryOpen);
    return self;
}

- (void)closePort {
	tcsetattr(fd, TCSANOW, &oldtio);
	close(fd);
}

- (NSInteger)writeBytes:(unsigned char *)bytes withSize:(NSInteger)size {
	return write(fd, bytes, size);
}

- (NSInteger)writeString:(NSString *)string {
	return write(fd, [string cStringUsingEncoding:NSUTF8StringEncoding], string.length);
}

- (NSInteger)readBytes:(unsigned char *)bytes maxSize:(NSInteger)size {
	return read(fd, bytes, size);
}

- (NSString *)readStringWithTimeOut:(double)timeOut {
    char buffer[256];
	[NSThread sleepForTimeInterval:timeOut];
	NSInteger bytes = read(fd, &buffer, sizeof(buffer));
    if (bytes > 0) {
        return [NSString stringWithUTF8String:(const char *)&buffer];
    }
    return @"";
}

@end
