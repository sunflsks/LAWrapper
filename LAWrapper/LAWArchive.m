#import "LAWArchive.h"
#import "LAWArchiveEntry.h"
#import <Foundation/Foundation.h>
#import <archive.h>
#import <archive_entry.h>

@implementation LAWArchive {
    NSString* _path;
    struct archive* _archive;
}

- (instancetype)initWithArchiveAtPath:(NSString*)path {
    self = [super init];
    if (!self)
        return nil;

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"File does not exist at path %@.", path);
        return nil;
    }

    _path = path;

    [self resetArchiveStruct];

    return self;
}

// This method is necessary because libarchive cannot seek through the archive, so it needs
// to be closed and reopened for each successive operation.
- (BOOL)resetArchiveStruct {
    if (_archive) {
        archive_read_close(_archive);
        archive_read_free(_archive);
    }

    _archive = archive_read_new();
    archive_read_support_format_all(_archive);
    archive_read_support_filter_all(_archive);

    int rc = archive_read_open_filename(_archive, [_path UTF8String], 9128);
    if (rc != ARCHIVE_OK) {
        NSLog(@"Couldn't open archive at path %@: %s", _path, archive_error_string(_archive));
        return NO;
    }

    return YES;
}

- (BOOL)extractArchiveToDirectory:(NSString*)dir withOptions:(ExtractionOptions*)options {
    // Credit to the examples page on the libarchive wiki
    [self resetArchiveStruct];
    struct archive* out;
    int rc;
    BOOL ret = YES;
    struct archive_entry* entry;

    out = archive_write_disk_new();
    archive_write_disk_set_options(out, [options flagValue]);

    if (options.passphrase || [options.passphrase length] > 0)
        archive_read_add_passphrase(out, options.passphrase.UTF8String);

    archive_write_disk_set_standard_lookup(out);

    while (true) {
        rc = archive_read_next_header(_archive, &entry);
        if (rc == ARCHIVE_EOF)
            break;

        NSLog(@"Extracting file %s", archive_entry_pathname(entry));

        if (rc < ARCHIVE_OK) {
            ret = NO;
            NSLog(@"Error while reading header: %s", archive_error_string(_archive));
        }

        if (rc < ARCHIVE_WARN) {
            NSLog(@"FAILURE while reading header!");
        }

        if (dir != nil) {
            archive_entry_set_pathname(
              entry,
              [[NSString stringWithFormat:@"%@/%s", dir, archive_entry_pathname(entry)]
                UTF8String]);
        }

        if (archive_entry_hardlink(entry)) {
            archive_entry_set_hardlink(
              entry,
              [[NSString stringWithFormat:@"%@/%s", dir, archive_entry_hardlink(entry)]
                UTF8String]);
        }

        rc = archive_write_header(out, entry);
        if (rc < ARCHIVE_OK) {
            ret = NO;
            NSLog(@"Error while writing header: %s", archive_error_string(out));
        }

        else if (archive_entry_size(entry) > 0) {
            rc = [self copyDataFromReadArchive:_archive toWriteArchive:out];
            ret = rc;
        }
    }

    return ret;
}

- (NSArray<LAWArchiveEntry*>*)archiveEntries {
    [self resetArchiveStruct];

    struct archive_entry* entry;
    int rc;
    NSMutableArray* ret = [[NSMutableArray alloc] init];

    while (true) {
        rc = archive_read_next_header(_archive, &entry);
        if (rc == ARCHIVE_EOF) {
            break;
        }

        if (rc < ARCHIVE_OK) {
            NSLog(@"Warning while reading entries into array: %s", archive_error_string(_archive));
        }

        if (rc < ARCHIVE_WARN) {
            NSLog(@"CRITICAL ERROR! %s", archive_error_string(_archive));
            break;
        }

        [ret addObject:[[LAWArchiveEntry alloc] initWithArchiveStruct:entry]];
    }

    return ret;
}

- (BOOL)copyDataFromReadArchive:(struct archive*)archive toWriteArchive:(struct archive*)out {
    int rc;
    const void* buffer;
    size_t size;
    la_int64_t offset;

    while (true) {
        rc = archive_read_data_block(archive, &buffer, &size, &offset);
        if (rc == ARCHIVE_EOF) {
            return TRUE;
        }

        if (rc < ARCHIVE_OK) {
            NSLog(@"Error while reading data into buffer: %s", archive_error_string(archive));
            return FALSE;
        }

        rc = archive_write_data_block(out, buffer, size, offset);
        if (rc < ARCHIVE_OK) {
            NSLog(@"Error while reading data into buffer: %s", archive_error_string(out));
        }
    }
}

- (void)dealloc {
    if (_archive) {
        archive_read_close(_archive);
        archive_read_free(_archive);
    }
}

@end
