//
//  AWAppDelegate.h
//  FileNotificationTester
//
//  Created by Amit Wolfus on 9/25/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWAppDelegate : NSObject <NSApplicationDelegate,
                                     NSOutlineViewDataSource>

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSMutableArray *trackedFiles;
@property (assign) IBOutlet NSOutlineView *outline;

- (IBAction)trackFile:(id)sender;

@end
