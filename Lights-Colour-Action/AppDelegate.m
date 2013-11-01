//
//  AppDelegate.m
//  Lights-Colour-Action
//
//  Created by Mike Griebling on 27 Oct 2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "AppDelegate.h"
#import "USBCom.h"


@implementation AppDelegate {
    USBCom *port;
    NSArray *ports;
    NSMutableDictionary *activeScape;
}

- (void)inspect:(NSArray *)selectedObjects {	// user double-clicked an item in the table
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Observe changes to colour values so we can update the derived Colour field
    if ([keyPath isEqualToString:@"arrangedObjects.redvalue"] || [keyPath isEqualToString:@"arrangedObjects.bluevalue"] ||
        [keyPath isEqualToString:@"arrangedObjects.greenvalue"] || [keyPath isEqualToString:@"arrangedObjects.whitevalue"]) {
        [self.colourTable setNeedsDisplay];
    }
    NSLog(@"Updating something...");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ports = [USBCom getPortNames];
    
    // monitor changes to data
    [self.colourValues addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.redvalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.bluevalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.greenvalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.whitevalue" options:NSKeyValueObservingOptionNew context:NULL];
    
    // set up the initial colour scenes
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @(1), @"number", @"◉", @"colourvalue", @(0), @"redvalue", @(10), @"bluevalue", @(20), @"greenvalue",
                                 @(30), @"whitevalue", @(50), @"rampvalue", @(60), @"holdvalue",
                                 nil];
    [self.colourValues addObject:data];
    
    // set up the initial light scapes
    activeScape = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Initial Lights", @"name", data, @"scenes", @(1), @"size", nil];
    [self.lightScapes addObject:activeScape];
    
//    // set up the initial preferences
//    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(1), @"daylighton", @(10), @"turnondelay", @(10), @"turnoffdelay",
//                                  @(6*60), @"timeon", @(0), @"firstsequence", @(0), @"totalsequences", @(0), @"firstmacro", @(255), @"protocoladdress", nil];
//    [self.preferences addObject:prefs];
}

- (IBAction)testSetting:(id)sender {
}

- (IBAction)addTableRow:(id)sender {
    NSMutableDictionary *rowValues = [self.colourValues valueAtIndex:0 inPropertyWithKey:@"arrangedObjects"];
    NSNumber *total = @(rowValues.count+1);
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 total, @"number", @"◉", @"colourvalue", @(0), @"redvalue", @(10), @"bluevalue", @(20), @"greenvalue",
                                 @(30), @"whitevalue", @(50), @"rampvalue", @(60), @"holdvalue",
                                 nil];
    [self.colourValues addObject:data];
    [activeScape setObject:total forKey:@"size"];
}

- (IBAction)deleteTableRow:(id)sender {
    [self.colourValues removeObjectAtArrangedObjectIndex:[self.colourValues selectionIndex]];
}

- (IBAction)addLightScape:(id)sender {
}

- (IBAction)deleteLightScape:(id)sender {
}

#pragma mark - NSTableView delegate method

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Change the colour cell's background colour based on the RGB values in the model
    NSString *columnName = [tableColumn identifier];
    if ([columnName isEqualToString:@"Colour"]) {
        NSMutableDictionary *rowValues = [self.colourValues valueAtIndex:row inPropertyWithKey:@"arrangedObjects"];
        NSNumber *red = [rowValues valueAtIndex:0 inPropertyWithKey:@"redvalue"];
        NSNumber *blue = [rowValues valueAtIndex:0 inPropertyWithKey:@"bluevalue"];
        NSNumber *green = [rowValues valueAtIndex:0 inPropertyWithKey:@"greenvalue"];
        NSNumber *white = [rowValues valueAtIndex:0 inPropertyWithKey:@"whitevalue"];
        [cell setBackgroundColor:[NSColor colorWithCalibratedRed:red.integerValue/255.0 green:green.integerValue/255.0 blue:blue.integerValue/255.0 alpha:1.0]];
        [cell setTextColor:[NSColor colorWithCalibratedWhite:white.integerValue/255.0 alpha:1.0]];
    }
}


@end
