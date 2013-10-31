//
//  MGIntegerTransformer.m
//  Lights → Colour → Action
//
//  Created by Michael Griebling on 30Oct2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "MGIntegerTransformer.h"

@implementation MGIntegerTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    float inputValue;
    NSInteger intValue;
    
    // handle error conditions
    if (value == nil) return nil;
    if ([value respondsToSelector:@selector(floatValue)]) {
        inputValue = [value floatValue];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Value (%@) does not respond to -floatValue.", [value class]];
    }
    
    // calculate the integer value
    intValue = round(inputValue);
    return @(intValue);
}

- (id)reverseTransformedValue:(id)value {
    float inputValue;
    NSInteger intValue;
    
    // handle error conditions
    if (value == nil) return nil;
    if ([value respondsToSelector:@selector(floatValue)]) {
        inputValue = [value floatValue];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Value (%@) does not respond to -floatValue.", [value class]];
    }
    
    // calculate the integer value
    intValue = round(inputValue);
    return @(intValue);
}

@end
