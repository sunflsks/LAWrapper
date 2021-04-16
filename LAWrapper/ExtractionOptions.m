#import "ExtractionOptions.h"
#import <Foundation/Foundation.h>
#import <archive.h>

@implementation ExtractionOptions

+ (instancetype)defaultFlags {
    ExtractionOptions* ret = [[ExtractionOptions alloc] init];
    ret.keepACL = NO;
    ret.keepFFlags = NO;
    ret.keepOwner = YES;
    ret.keepPermissions = YES;
    ret.keepTime = YES;
    ret.unlinkBeforeCreate = NO;
    ret.keepXattrs = NO;

    return ret;
}

- (int)flagValue {
    int rc = 0;

    rc |= self.keepACL ? ARCHIVE_EXTRACT_ACL : 0;
    rc |= self.keepFFlags ? ARCHIVE_EXTRACT_FFLAGS : 0;
    rc |= self.keepOwner ? ARCHIVE_EXTRACT_OWNER : 0;
    rc |= self.keepPermissions ? ARCHIVE_EXTRACT_PERM : 0;
    rc |= self.keepTime ? ARCHIVE_EXTRACT_TIME : 0;
    rc |= self.unlinkBeforeCreate ? ARCHIVE_EXTRACT_UNLINK : 0;
    rc |= self.keepXattrs ? ARCHIVE_EXTRACT_XATTR : 0;

    return rc;
}

@end

