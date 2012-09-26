//
//  AWAppDelegate.m
//  FileNotificationTester
//
//  Created by Amit Wolfus on 9/25/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "AWAppDelegate.h"

@implementation AWAppDelegate

@synthesize trackedFiles;

- (id)init {
  if (self = [super init]) {
    trackedFiles = [[NSMutableArray alloc] initWithCapacity:0];
  }
  return self;
}

- (void)dealloc
{
  [trackedFiles release];
  [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
}

- (IBAction)trackFile:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  if ([openPanel runModal] == NSOKButton) {
    NSArray *selectedFiles = [openPanel URLs];
    for (NSURL *url in selectedFiles) {
      [trackedFiles addObject:url];
    }
    [[self outline] reloadData];
  }
}
-(void)printArr:(NSArray *)arr {
  for (id obj in arr) {
    NSLog(@"%@", obj);
  }
}
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  return NO;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return NO;
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  if (item) {
    return 0;
  }
  return [trackedFiles count];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
  return NO;
}
-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  if (item) {
    return nil;
  }
  return [trackedFiles objectAtIndex:index];
}
-(void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
  
}

@end
