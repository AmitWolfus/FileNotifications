//
//  AWFileListener.h
//  FileNotifications
//
//  Created by Amit Wolfus on 9/22/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "AWFileConstants.h"

/**
 * An enum describing possible changes for a file
 */
typedef enum AWFileChangeType {
  AWFileSame = 0,
  AWFileDeleted,
  AWFileUpdated
} AWFileChangeType;

/**
 * AWFileListenerDelegate defines a delegate for the AWFileListener,
 * the delegate will be forwarded with changes to registered files
 */
@protocol AWFileListenerDelegate <NSObject>

- (void)fileWasChanged:(AWFileChangeType)changeType atPath:(NSString *)path;

@end

/**
 * AWFileListener is responsible for communicating with the file system
 * and analyzing file changes.
 *
 * All found changes will be notified to the listener's delegate
 */
@interface AWFileListener : NSObject {
  id <AWFileListenerDelegate> delegate_;
}

@property(nonatomic, assign) id <AWFileListenerDelegate> delegate;

- (id)initWithDelegate:(id <AWFileListenerDelegate>)delegate;
- (BOOL)trackFileAt:(NSURL *)url error:(NSError **)error;

@end
