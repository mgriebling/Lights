//
//  AppDelegate.m
//  Lights-Colour-Action
//
//  Created by Mike Griebling on 27 Oct 2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "AppDelegate.h"
#import "Controller.h"
#import "USBCom.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSButton *deleteScene;
@property (weak) IBOutlet NSButton *deleteScape;
@property (weak) IBOutlet NSLevelIndicator *memoryLevel;
@property (weak) IBOutlet NSComboBox *activeLightScape;
@property (weak) IBOutlet NSComboBox *controllerPort;
@property (weak) IBOutlet NSComboBox *portBaudRate;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSButton *loadControllerButton;

@end

@implementation AppDelegate {
    Controller *controller;
    NSMutableDictionary *activeScape;
    NSMutableDictionary *activeScene;
}

- (NSArray *)ports {
    if (!_ports) {
        _ports = [USBCom getPortNames];
    }
    return _ports;
}

- (void)inspect:(NSArray *)selectedObjects {	// user double-clicked an item in the table
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Observe changes to colour values so we can update the derived Colour field
    if ([keyPath isEqualToString:@"arrangedObjects.redvalue"] || [keyPath isEqualToString:@"arrangedObjects.bluevalue"] ||
        [keyPath isEqualToString:@"arrangedObjects.greenvalue"] || [keyPath isEqualToString:@"arrangedObjects.whitevalue"]) {
        [activeScene setObject:@"◉" forKey:@"colourvalue"];   // force an update of this field
    } else if ([keyPath isEqualToString:@"selectionIndexes"]) {
        // new active row - cache locally
        NSArray *active = [self.colourValues selectedObjects];
        activeScene = [active lastObject];
//        NSLog(@"Selected %@", active);
    }
}

- (void)initPreferences {
    self.daylightDetectionEnabled = @(1);
    self.turnOnTimeDelay = @(10);
    self.turnOffTimeDelay = @(10);
    self.totalOnTime = @(6*60);
    self.firstSequence = @(0);
    self.numberOfSequences = @(0);
    self.protocolAddress = @(255);
    self.firstEEPROMMacro = @(0);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // monitor changes to data
    [self.colourValues addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.redvalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.bluevalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.greenvalue" options:NSKeyValueObservingOptionNew context:NULL];
    [self.colourValues addObserver:self forKeyPath:@"arrangedObjects.whitevalue" options:NSKeyValueObservingOptionNew context:NULL];

    [self addLightScape:self];
    
    // set up the controls
//    [self.controllerPort addItemsWithObjectValues:self.ports];
    [self.controllerPort setStringValue:self.ports[0]];
//    [self.portBaudRate addItemsWithObjectValues:@[@"9600", @"19200", @"38400"]];
//    [self.portBaudRate setStringValue:@"9600"];
//    NSArray *scapes = [self.lightScapes arrangedObjects];
    [self.activeLightScape addItemsWithObjectValues:@[[activeScape objectForKey:@"name"]]];
    [self.activeLightScape setStringValue:[activeScape objectForKey:@"name"]];
    
    // set up the macros
     NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
        @(1), @"number", @"◉", @"colourvalue", @(0), @"redvalue", @(0), @"bluevalue", @(0), @"greenvalue", @(0), @"whitevalue", @(0), @"rampvalue", @(0), @"holdvalue",
        nil];
    [self.macros addObject:data];
    
    // set up the initial preferences
    [self initPreferences];
}

- (IBAction)testSetting:(id)sender {
}

- (IBAction)addTableRow:(id)sender {
    NSNumber *total = @([[self.colourValues arrangedObjects] count]+1);
    NSMutableDictionary *data = [[[self.colourValues selectedObjects] lastObject] mutableCopy];
    if (data == nil) {
        data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                total, @"number", @"◉", @"colourvalue", @(0), @"redvalue", @(0), @"bluevalue", @(0), @"greenvalue", @(0), @"whitevalue", @(0), @"rampvalue", @(0), @"holdvalue",
                nil];
    }
    [data setObject:total forKey:@"number"];        // set the scene's row number
    [self.colourValues addObject:data];
    activeScene = data;
    [activeScape setObject:total forKey:@"size"];   // update the number of items in the light scape
    [self.deleteScene setEnabled:total.integerValue > 1];
}

- (IBAction)deleteTableRow:(id)sender {
    [self.colourValues removeObjectAtArrangedObjectIndex:[self.colourValues selectionIndex]];
    NSInteger total = [[self.colourValues arrangedObjects] count];
    [activeScape setObject:@(total) forKey:@"size"];                // update the number of items in the light scape
    [self.deleteScene setEnabled:total > 1];
}

- (IBAction)addLightScape:(id)sender {
    unsigned long total = [[self.lightScapes arrangedObjects] count]+1;
    activeScape = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Light Scape %lu", total], @"name", activeScene, @"scenes", @(1), @"size", nil];
    [self.colourValues removeObjects:[self.colourValues arrangedObjects]];
    [self.lightScapes addObject:activeScape];
    [self addTableRow:sender];
}

- (IBAction)deleteLightScape:(id)sender {
}

- (IBAction)connectToPort:(id)sender {
    controller = [[Controller alloc] init];
    if ([self.connectButton.title isEqualToString:@"Connect"]) {
        if ([controller connectToPort:self.controllerPort.stringValue withBaudRate:self.portBaudRate.stringValue]) {
            [self.connectButton setTitle:@"Disconnect"];
        }
    } else {
        controller = nil;       // also disconnects port
        [self.connectButton setTitle:@"Connect"];
    }
}

- (IBAction)loadSaveFromController:(id)sender {
}

#pragma mark - NSTableView delegate method

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Change the colour cell's background colour based on the RGB values in the model
    NSString *columnName = [tableColumn identifier];
//    NSLog(@"In cell display for column %@", columnName);
    if ([columnName isEqualToString:@"Colour"]) {
        NSMutableDictionary *rowValues = [self.colourValues valueAtIndex:row inPropertyWithKey:@"arrangedObjects"];
        NSNumber *red = [rowValues valueAtIndex:0 inPropertyWithKey:@"redvalue"];
        NSNumber *blue = [rowValues valueAtIndex:0 inPropertyWithKey:@"bluevalue"];
        NSNumber *green = [rowValues valueAtIndex:0 inPropertyWithKey:@"greenvalue"];
        NSNumber *white = [rowValues valueAtIndex:0 inPropertyWithKey:@"whitevalue"];
        [cell setBackgroundColor:[NSColor colorWithCalibratedRed:red.integerValue/255.0 green:green.integerValue/255.0 blue:blue.integerValue/255.0 alpha:1.0]];
        [cell setTextColor:[NSColor colorWithCalibratedWhite:white.integerValue/255.0 alpha:1.0]];
//        NSLog(@"Changing colours to R:%@ G:%@ B:%@ W:%@", red, green, blue, white);
    }
}


@end
