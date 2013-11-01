//
//  AppDelegate.h
//  Lights-Colour-Action
//
//  Created by Mike Griebling on 27 Oct 2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

@property (weak) IBOutlet NSArrayController *colourValues;
@property (weak) IBOutlet NSArrayController *lightScapes;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *colourTable;
@property (weak) IBOutlet NSSlider *redSlider;
@property (weak) IBOutlet NSSlider *greenSlider;
@property (weak) IBOutlet NSSlider *blueSlider;
@property (weak) IBOutlet NSSlider *whiteSlider;
@property (weak) IBOutlet NSSlider *holdSlider;
@property (weak) IBOutlet NSSlider *rampSlider;
@property (weak) IBOutlet NSTextField *redField;
@property (weak) IBOutlet NSTextField *greenField;
@property (weak) IBOutlet NSTextField *blueField;
@property (weak) IBOutlet NSTextField *whiteField;
@property (weak) IBOutlet NSTextField *holdField;
@property (weak) IBOutlet NSTextField *rampField;

- (void)inspect:(NSArray *)selectedObjects;		// user double-clicked an item in the table

@end
