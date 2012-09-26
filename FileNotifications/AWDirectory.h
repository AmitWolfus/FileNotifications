//
//  AWDirectory.h
//  FileNotifications
//
//  Created by Amit Wolfus on 9/24/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "AWFileConstants.h"

#pragma mark AWFile

/**
 * Represents a file with file attributes and an hash sum
 */
@interface AWFile : NSObject{

}

@property(nonatomic, retain) NSString *path;
@property(nonatomic, retain) NSDate *creationDate;
@property(nonatomic, retain) NSDate *modificationDate;
@property(nonatomic, retain) NSString *authenticationHash;

- (id)initWithUrl:(NSURL *)fileUrl;

+ (BOOL)fileExists:(NSURL *)url;
+ (NSString *)generateAuthenticationHashForFileAt:(NSURL *)url
                                            error:(NSError **)error;

@end

/**
 * Represents a directory in the file system with subdirs and files
 */
@interface AWDirectory : NSObject
/**
 * A dictionary containing all the sub directories as AWDirectory* keyed
 * by the directories' names
 */
@property(nonatomic, readonly) NSDictionary *subDirectories;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary *files;
@property(nonatomic, readonly) NSString *path;

- (void)addSubDirectory:(AWDirectory *)subDirectory;
- (void)removeSubDirectory:(NSString *)subDirectoryName;
- (void)addFile:(AWFile *)file;
- (void)removeFile:(AWFile *)file;
/**
 * Attemps to get a sub directory recursivly.
 *
 * @param relativeDirectory The desired directory's path relative to the
 * receiving directory.
 *
 * @param create Should a directory be created if it doesn't exist 
 * in the directories tree.
 *
 * @param error Contains an NSError if there was any error or nil otherwise,
 * pass nil if an error shouldn't be returned.
 */
- (AWDirectory *)getSubDirectory:(NSString *)relativeDirectory
               createNonExisting:(BOOL)create
                           error:(NSError **)error;
- (NSArray *)nonEmptySubDirectoriesPaths;
- (BOOL)isEmpty;

/**
 * Creates a directory representing a root directory.
 * 
 * this is the only way to create an AWDirectory and should only be used 
 * for root directories, all other contained directories should be created
 * using the getSubDirectory method with createNonExisting:YES.
 *
 * @param URL The URL of the root directory, for example: "/".
 */
+ (AWDirectory *)createRootDirectoryWithURL:(NSURL *)URL;

@end
