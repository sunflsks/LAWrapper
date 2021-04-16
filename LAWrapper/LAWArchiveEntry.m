#import "LAWArchiveEntry.h"
#import <Foundation/Foundation.h>
#import <archive.h>
#import <archive_entry.h>

@implementation LAWArchiveEntry {
    BOOL setbirthtime;
    BOOL setgid;
    BOOL sethardlink;
    BOOL setpathname;
    BOOL setsize;
    BOOL setsymlink;
    BOOL setuid;

    NSInteger birthtime;
    gid_t gid;
    uid_t uid;
    NSString* hardlink;
    NSString* pathname;
    NSInteger size;
    NSString* symlink;
    struct archive_entry* _entry;
}

- (instancetype)initWithArchiveStruct:(struct archive_entry*)entry {
    self = [super init];
    if (!self || !entry)
        return nil;

    _entry = archive_entry_clone(entry);

    return self;
}

- (NSInteger)birthtime {
    if (!setbirthtime) {
        setbirthtime = YES;
        birthtime = archive_entry_birthtime(_entry);
    }

    return birthtime;
}

- (gid_t)gid {
    if (!setgid) {
        setgid = YES;
        gid = archive_entry_gid(_entry);
    }

    return gid;
}

- (uid_t)uid {
    if (!setuid) {
        setuid = YES;
        uid = archive_entry_uid(_entry);
    }

    return uid;
}

- (NSString*)hardlink {
    if (!sethardlink) {
        sethardlink = YES;
        hardlink = [[NSString alloc] initWithCString:archive_entry_hardlink(_entry)
                                            encoding:NSUTF8StringEncoding];
    }

    return hardlink;
}

- (NSString*)pathname {
    if (!setpathname) {
        setpathname = YES;
        pathname = [[NSString alloc] initWithCString:archive_entry_pathname(_entry)
                                            encoding:NSUTF8StringEncoding];
    }

    return pathname;
}

- (NSInteger)size {
    if (!setsize) {
        setsize = YES;
        size = archive_entry_size(_entry);
    }

    return size;
}

- (NSString*)symlink {
    if (!setsymlink) {
        setsymlink = YES;
        symlink = [[NSString alloc] initWithCString:archive_entry_symlink(_entry)
                                           encoding:NSUTF8StringEncoding];
    }

    return symlink;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@: owned by %d:%d with size %lu",
                                      self.pathname,
                                      self.uid,
                                      self.gid,
                                      (size_t)self.size];
}

- (void)dealloc {
    archive_entry_free(_entry);
}

@end
