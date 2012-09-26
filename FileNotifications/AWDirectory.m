//
//  AWDirectory.m
//  FileNotifications
//
//  Created by Amit Wolfus on 9/24/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "AWDirectory.h"
#include <zlib.h>


@implementation AWFile

@synthesize creationDate, modificationDate, authenticationHash, path;

- (id)initWithUrl:(NSURL *)fileUrl {
  if (self = [super init]) {
    if (![AWFile fileExists:fileUrl]) {
      return nil;
    }
    self.path = [fileUrl isFileURL] ? [fileUrl path] : [fileUrl absoluteString];
    NSDictionary *fileAttributes =
    [[NSFileManager defaultManager]
     attributesOfItemAtPath:[self path] error:nil];
    self.creationDate = [fileAttributes fileCreationDate];
    self.modificationDate = [fileAttributes fileModificationDate];
  }

  return self;
}

- (void)dealloc {
  [[self path] release];
  [creationDate release];
  [modificationDate release];
  [authenticationHash release];
  [super dealloc];
}

+ (BOOL)fileExists:(NSURL *)url {
  BOOL isDirectory;
  NSString *path = [url isFileURL] ? [url path] : [url absoluteString];
  BOOL exists =
  [[NSFileManager defaultManager] fileExistsAtPath:path
                                       isDirectory:&isDirectory];
  return exists && !isDirectory;
}

+ (NSString *)generateAuthenticationHashForFileAt:(NSURL *)url
                                            error:(NSError **)error {
  if (![AWFile fileExists:url]) {
    if (error) {
      *error = [NSError errorWithDomain:@"AWFileNotificationsError"
                                   code:1
                               userInfo:
                [NSDictionary dictionaryWithObjectsAndKeys:@"Reason",
                 @"File doesn't exist", nil]];
    }
    return nil;
  }
  NSString *path = [url isFileURL] ? [url path] : [url absoluteString];
  NSData *fileContent =
      [[NSFileManager defaultManager] contentsAtPath:path];
  uLong crc = crc32(0L, Z_NULL, 0);
  crc = crc32(crc, [fileContent bytes], (uint32_t)[fileContent length]);
  return [NSString stringWithFormat:@"%lu",crc];
}

@end

#pragma mark AWDirectory

@implementation AWDirectory {
  NSMutableDictionary *subDirectories_;
  NSMutableDictionary *files_;
  NSString *name_;
  NSURL *url_;
}

@synthesize subDirectories = subDirectories_, name = name_, files = files_;

- (NSString *)path {
  return [url_ path];
}

- (id)initWithName:(NSString *)name {
  return [self initWithName:name
             subDirectories:[NSArray arrayWithObjects:nil]
                      files:[NSArray arrayWithObjects:nil]];
}

- (id)initWithName:(NSString *)name subDirectories:(NSArray *)subDirs {
  return [self initWithName:name
             subDirectories:subDirs
                      files:[NSArray arrayWithObjects:nil]];
}

- (id)initWithName:(NSString *)name files:(NSArray *)files{
  return [self initWithName:name
             subDirectories:[NSArray arrayWithObjects:nil]
                      files:files];
}

// Designated initializer
- (id)initWithName:(NSString *)name
    subDirectories:(NSArray *)subDirs
             files:(NSArray *)files {
  if (self = [super init]) {
    name_ = [name retain];
    files_ = [[NSMutableDictionary alloc] initWithCapacity:[files count]];
    for (AWFile *file in files) {
      [files_ setObject:file forKey:[file url]];
    }
    subDirectories_ =
    [[NSMutableDictionary alloc] initWithCapacity:[subDirs count]];
    for (AWDirectory *directory in subDirs) {
      [subDirectories_ setObject:directory forKey:[directory name]];
    }
  }
  return self;
}

- (void)dealloc {
  [subDirectories_ release];
  [files_ release];
  [name_ release];
  [super dealloc];
}

- (void)addSubDirectory:(AWDirectory *)subDirectory {
  [subDirectories_ setObject:subDirectory forKey:[subDirectory name]];
}
- (void)removeSubDirectory:(NSString *)subDirectoryName {
  [subDirectories_ removeObjectForKey:subDirectoryName];
}
- (void)addFile:(AWFile *)file {
  [files_ setObject:file forKey:[file path]];
}
- (void)removeFile:(AWFile *)file {
  [files_ removeObjectForKey:[file path]];
}

- (AWDirectory *)getSubDirectory:(NSString *)relativeDirectory
               createNonExisting:(BOOL)create
                           error:(NSError **)error {
  NSArray *dirs = [relativeDirectory componentsSeparatedByString:@"/"];
  AWDirectory *upperDir = self;
  for (NSString *currSubDir in dirs) {
    if ([currSubDir compare:@""] == NSOrderedSame) {
      continue;
    }
    currSubDir = [NSString stringWithFormat:@"%@/", currSubDir];
    AWDirectory *dir = [[upperDir subDirectories] objectForKey:currSubDir];
    // Check if the directory already exists
    if (!dir) {
      // Check if the non-existent directory should be created
      if (!create) {
        if (error) {
          NSError *err =
          [NSError errorWithDomain:FILE_ERROR_DOMAIN
                              code:FILE_NOT_FOUND
                          userInfo:nil];
          *error = err;
        }
        return nil;
      }
      dir = [[[AWDirectory alloc] initWithName:currSubDir] autorelease];
      [upperDir addSubDirectory:dir];
    }
    dir->url_ = [[NSURL alloc] initWithString:currSubDir
                                relativeToURL:upperDir->url_];
    upperDir = dir;
  }
  *error = nil;
  return upperDir;
}

- (BOOL)isEmpty {
  return [[self files] count] == 0;
}

- (NSArray *)nonEmptySubDirectoriesPaths {
  NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
  for (AWDirectory *subDir in [self subDirectories]) {
    [paths addObjectsFromArray:[subDir nonEmptySubDirectoriesPaths]];
  }
  if (![self isEmpty]) {
    [paths addObject:[self path]];
  }
  return paths;
}

+ (AWDirectory *)createRootDirectoryWithURL:(NSURL *)URL {
  NSString *realPath = [URL isFileURL] ? [URL path] : [URL absoluteString];
  AWDirectory *rootDir =
      [[AWDirectory alloc] initWithName:realPath];
  rootDir->url_ = [NSURL URLWithString:realPath];

  return [rootDir autorelease];
}

@end
