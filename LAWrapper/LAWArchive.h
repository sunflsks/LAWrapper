#import "ExtractionOptions.h"
#import "LAWArchiveEntry.h"
#import <Foundation/Foundation.h>
#pragma once

@interface LAWArchive : NSObject
- (instancetype)initWithArchiveAtPath:(NSString*)path;
- (BOOL)extractArchiveToDirectory:(NSString*)dir withOptions:(ExtractionOptions*)options;
- (BOOL)resetArchiveStruct;
- (NSArray<LAWArchiveEntry*>*)archiveEntries;
@end
