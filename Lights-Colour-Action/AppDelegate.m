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
}

- (void)inspect:(NSArray *)selectedObjects {	// user double-clicked an item in the table
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Observe changes to colour values so we can update the derived Colour field
    if ([keyPath isEqualToString:@"arrangedObjects.redvalue"] || [keyPath isEqualToString:@"arrangedObjects.bluevalue"] ||
        [keyPath isEqualToString:@"arrangedObjects.greenvalue"] || [keyPath isEqualToString:@"arrangedObjects.whitevalue"]) {
        [self.colourTable setNeedsDisplay];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ports = [USBCom getPortNames];
    
    // monitor changes to data
    [self.colourValues addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.redvalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.bluevalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.greenvalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.whitevalue" options:NSKeyValueObservingOptionNew context:NULL];
    
    // set up the initial table data
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"◉", @"colourvalue", @(0), @"redvalue", @(10), @"bluevalue", @(20), @"greenvalue",
                                 @(30), @"whitevalue", @(50), @"rampvalue", @(60), @"holdvalue",
                                 nil];
    [self.colourValues addObject:data];
}

- (IBAction)testSetting:(id)sender {
}

- (IBAction)addTableRow:(id)sender {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"◉", @"colourvalue", @(0), @"redvalue", @(10), @"bluevalue", @(20), @"greenvalue",
                                 @(30), @"whitevalue", @(50), @"rampvalue", @(60), @"holdvalue",
                                 nil];
    [self.colourValues addObject:data];
}

- (IBAction)deleteTableRow:(id)sender {
    [self.colourValues removeObjectAtArrangedObjectIndex:[self.colourValues selectionIndex]];
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
