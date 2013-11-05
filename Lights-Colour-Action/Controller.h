//
//  Controller.h
//  Lights → Colour → Action
//
//  Created by Mike Griebling on 5 Nov 2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Controller : NSObject

- (BOOL)connectToPort:(NSString *)portName withBaudRate:(NSString *)baudRate;

- (NSArray *)readScenesFromSceneAddress:(NSInteger)sceneAddress withLength:(NSInteger)length;
- (BOOL)writeScenes:(NSArray *)scenes toSceneAddress:(NSInteger)sceneAddress;

- (NSArray *)readMacrosFromMacroAddress:(NSInteger)macroAddress withLength:(NSInteger)length;
- (BOOL)writeMacros:(NSArray *)macros toMacroAddress:(NSInteger)macroAddress;

- (NSDictionary *)readSettings;
- (BOOL)writeSettings:(NSDictionary *)settings;

- (BOOL)setColourWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue white:(NSInteger)white;

@end
