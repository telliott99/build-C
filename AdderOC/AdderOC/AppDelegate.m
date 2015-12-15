//
//  AppDelegate.m
//  AdderOC
//
//  Created by Tom Elliott on 12/15/15.
//  Copyright © 2015 Tom Elliott. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    int x = f1(1);
    printf("AD: %d;", x);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
