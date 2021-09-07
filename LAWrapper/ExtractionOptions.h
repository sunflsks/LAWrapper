#import <Foundation/Foundation.h>
#pragma once

@interface ExtractionOptions : NSObject
@property (readwrite, assign) BOOL keepACL;
@property (readwrite, assign) BOOL keepFFlags;
@property (readwrite, assign) BOOL keepOwner;
@property (readwrite, assign) BOOL keepPermissions;
@property (readwrite, assign) BOOL keepTime;
@property (readwrite, assign) BOOL unlinkBeforeCreate;
@property (readwrite, assign) BOOL keepXattrs;
@property (nonatomic) NSString* passphrase;
+ (instancetype)defaultFlags;
- (int)flagValue;
@end
