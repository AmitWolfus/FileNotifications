//
//  AWFileListener.m
//  FileNotifications
//
//  Created by Amit Wolfus on 9/22/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "AWFileListener.h"
#import "AWDirectory.h"
#include <CoreServices/CoreServices.h>

#pragma mark AWFileListener

@implementation AWFileListener{
  AWDirectory *rootDir_;
  NSMutableArray *registeredPaths_;
  FSEventStreamRef eventStream_;
  UInt64 sinceWhen_;
}

const CFTimeInterval LATENCY = 3.0;

@synthesize delegate = delegate_;

- (id)initWithDelegate:(id<AWFileListenerDelegate>)delegate {
  if (self = [super init]) {
    [self setDelegate:delegate];
  }
  rootDir_ =
      [[AWDirectory createRootDirectoryWithURL:
        [NSURL URLWithString:@"/"]] retain];
  registeredPaths_ = [[NSMutableArray alloc] initWithCapacity:0];
  sinceWhen_ = kFSEventStreamEventIdSinceNow;
  eventStream_ = NULL;
  return self;
}

- (void)dealloc {
  [rootDir_ release];
  [registeredPaths_ release];
  [super dealloc];
}

- (void)setDelegate:(id<AWFileListenerDelegate>)delegate {
  if (eventStream_) {
    releaseFSEventStream(eventStream_);
    eventStream_ = NULL;
  }
  if (delegate) {
    delegate_ = delegate;
  }
}

- (BOOL)trackFileAt:(NSURL *)url error:(NSError **)error {
  if (![AWFile fileExists:url]) {
    if (error) {
      *error = [NSError errorWithDomain:FILE_ERROR_DOMAIN
                                   code:FILE_NOT_FOUND
                               userInfo:nil];
    }
    return NO;
  }
  AWDirectory *containingDir = [rootDir_ getSubDirectory:[url path]
                                       createNonExisting:YES
                                                   error:error];
  if (!error) {
    return NO;
  }
  if ([[containingDir files] objectForKey:url]) {
    *error = nil;
    return NO;
  }
  BOOL wasDirectoryEmpty = [containingDir isEmpty];
  AWFile *addedFile = [[AWFile alloc] initWithUrl:url];
  [containingDir addFile:[addedFile autorelease]];
  if (wasDirectoryEmpty) {
    [registeredPaths_ addObject:[containingDir path]];
    [self resetFileEventsListener];
  }
  return YES;
}

void releaseFSEventStream(FSEventStreamRef stream) {
  FSEventStreamStop(stream);
  FSEventStreamUnscheduleFromRunLoop(stream,
                                     CFRunLoopGetMain(),
                                     kCFRunLoopDefaultMode);
  FSEventStreamInvalidate(stream);
  FSEventStreamRelease(stream);
}

// Available event flags are of the following:
// kFSEventStreamEventFlagNone   = 0x00000000,
// kFSEventStreamEventFlagMustScanSubDirs = 0x00000001,
// kFSEventStreamEventFlagUserDropped = 0x00000002,
// kFSEventStreamEventFlagKernelDropped = 0x00000004,
// kFSEventStreamEventFlagEventIdsWrapped = 0x00000008,
// kFSEventStreamEventFlagHistoryDone = 0x00000010,
// kFSEventStreamEventFlagRootChanged = 0x00000020,
// kFSEventStreamEventFlagMount  = 0x00000040,
// kFSEventStreamEventFlagUnmount = 0x00000080,
// kFSEventStreamEventFlagItemCreated = 0x00000100,
// kFSEventStreamEventFlagItemRemoved = 0x00000200,
// kFSEventStreamEventFlagItemInodeMetaMod = 0x00000400,
// kFSEventStreamEventFlagItemRenamed = 0x00000800,
// kFSEventStreamEventFlagItemModified = 0x00001000,
// kFSEventStreamEventFlagItemFinderInfoMod = 0x00002000,
// kFSEventStreamEventFlagItemChangeOwner = 0x00004000,
// kFSEventStreamEventFlagItemXattrMod = 0x00008000,
// kFSEventStreamEventFlagItemIsFile = 0x00010000,
// kFSEventStreamEventFlagItemIsDir = 0x00020000,
// kFSEventStreamEventFlagItemIsSymlink = 0x00040000

// Resets the current FSEventStream to listen to the current registeredPaths
// array, this method should be called after a path is added or removed to
// the registered paths
- (void)resetFileEventsListener {
  if (eventStream_) {
    releaseFSEventStream(eventStream_);
  }
  eventStream_ = FSEventStreamCreate(NULL,
                                     &fileChangedCallback,
                                     (void *)self,
                                     registeredPaths_,
                                     sinceWhen_,
                                     LATENCY,
                                     kFSEventStreamCreateFlagFileEvents |
                                     kFSEventStreamCreateFlagUseCFTypes);
  FSEventStreamScheduleWithRunLoop(eventStream_,
                                   CFRunLoopGetMain(),
                                   kCFRunLoopDefaultMode);
  FSEventStreamStart(eventStream_);
}

void fileChangedCallback(ConstFSEventStreamRef streamRef,
                         void *clientCallBackInfo,
                         size_t numEvents,
                         void *eventPaths,
                         const FSEventStreamEventFlags eventFlags[],
                         const FSEventStreamEventId eventIds[]) {
  // Go over all the received events
  for (int index = 0; index < numEvents; index++) {
    FSEventStreamFlags currFlag = eventFlags[index];
    CFStringRef currPath = eventPaths[index];
    FSEventStreamId eventId = eventIds[index];
    // TODO: Actually handle the event...
  }
}

@end
