#ifndef BASIC_DSK_RSDOS_H_
#define BASIC_DSK_RSDOS_H_

// This will be a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild

#import "kaitai/kaitaistruct.h"

#if KAITAI_STRUCT_VERSION < 7000L
#error "Incompatible Kaitai Struct C++/STL API: version 0.7 or later is required"
#endif

typedef NS_ENUM(uint8_t, file_type_t) {
        FILE_TYPE_BASIC_PROGRAM = 0,
        FILE_TYPE_BASIC_DATA_FILE = 1,
        FILE_TYPE_MACHINE_LANGUAGE_PROGRAM = 2,
        FILE_TYPE_TEXT_EDITOR_SOURCE_FILE = 3
};

typedef NS_ENUM(uint8_t, ascii_flag_t) {
        ASCII_FLAG_BINARY = 0,
        ASCII_FLAG_ASCII = 255
};

@class granule_basic_dsk_rsdos_t;
@class file_allocation_table_basic_dsk_rsdos_t;
@class file_basic_dsk_rsdos_t;
@class granule_ptr_basic_dsk_rsdos_t;

@interface basic_dsk_rsdos_t : kstruct

{

}

-(void)_read;

@property (strong) kstruct *_parent;
@property (strong) basic_dsk_rsdos_t *_root;

@property (strong) NSMutableArray<granule_basic_dsk_rsdos_t *> *granules1;
@property (strong) NSData *reserved1;
@property (strong) file_allocation_table_basic_dsk_rsdos_t *fat;
@property (strong) NSMutableArray<file_basic_dsk_rsdos_t *> *files;
@property (strong) NSData *reserved2;
@property (strong) NSMutableArray<granule_basic_dsk_rsdos_t *> *granules2;

@property (strong) NSMutableArray<NSData *> *_raw_granules1;
@property (strong) NSMutableArray<kstream *> *_io__raw_granules1;
@property (strong) NSData *_raw_fat;
@property (strong) kstream *_io__raw_fat;
@property (strong) NSMutableArray<NSData *> *_raw_granules2;
@property (strong) NSMutableArray<kstream *> *_io__raw_granules2;

@end

@interface granule_basic_dsk_rsdos_t : kstruct
{
}

-(void)_read;

@property (strong) basic_dsk_rsdos_t *_parent;
@property (strong) basic_dsk_rsdos_t *_root;

@property (strong) NSData *bytes;

@end

@interface file_allocation_table_basic_dsk_rsdos_t : kstruct
{
}

-(void)_read;

@property (strong) basic_dsk_rsdos_t *_parent;
@property (strong) basic_dsk_rsdos_t *_root;

@property (strong) NSMutableArray<NSNumber *> *table;
@property (strong) NSData *reserved;

@end

@interface file_basic_dsk_rsdos_t : kstruct
{
}

-(void)_read;

@property (strong) NSString *name;
@property (strong) NSString *extension;
@property (strong) NSDictionary *file_type;
@property (strong) NSDictionary *ascii_flag;
@property (strong) granule_ptr_basic_dsk_rsdos_t *ofs_granule;
@property (strong) NSNumber *bytes_in_last_sector;
@property (strong) NSData *reserved;

@end

@interface granule_ptr_basic_dsk_rsdos_t : kstruct
{
    NSData *_body;
    granule_ptr_basic_dsk_rsdos_t *_next;
}

-(void)_read;

@property (strong) file_basic_dsk_rsdos_t *_parent;
@property (strong) basic_dsk_rsdos_t *_root;

@property (strong) NSNumber *current_ptr;
@property (strong, readonly) NSData *body;
@property (strong, readonly) granule_ptr_basic_dsk_rsdos_t *next;

@end

#endif  // BASIC_DSK_RSDOS_H_
