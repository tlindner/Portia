#import "basic_dsk_rsdos.h"

@implementation basic_dsk_rsdos_t

@dynamic _enumerations;
@dynamic _root;
@dynamic _parent;

- (NSDictionary *)_enumerations
{
    if (_enumerations == nil) {
        _enumerations = @{ @"FILE_TYPE" : @{ @"BASIC_PROGRAM": @(0),
                                             @"BASIC_DATA_FILE" : @(1),
                                             @"LANGUAGE_PROGRAM" : @(2),
                                             @"TEXT_EDITOR_SOURCE_FILE": @(3)},
                           
                           @"ASCII_FLAG" : @{ @"BINARY" : @(0),
                                              @"ASCII" : @(255)} };
    }
    
    return _enumerations;
}

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root
{
    return [[basic_dsk_rsdos_t alloc] initWith:p__io withStruct:p__parent withRoot:p__root];
}

+ (instancetype) structWith:(kstream *)stream
{
    return [[basic_dsk_rsdos_t alloc] initWith:stream withStruct:nil withRoot:nil];
}

- (instancetype) initWith:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot:(basic_dsk_rsdos_t *)p__root
{
    self = [super initWith:p__io withStruct:p__parent withRoot:p__root];
    if (self) {
        [self _read];
    }
    return self;
}

-(void)_read
{
    NSUInteger l_granules = (17 * 2);
    self._raw_granules1 = [NSMutableArray arrayWithCapacity:l_granules];
    self._io__raw_granules1 = [NSMutableArray arrayWithCapacity:l_granules];
    self.granules1 = [NSMutableArray arrayWithCapacity:l_granules];
    for (int i = 0; i < l_granules; i++) {
        [self._raw_granules1 addObject:[self._io read_bytes:((9 * 256))]];
        kstream *io__raw_granules1 = [kstream streamWithData:(self._raw_granules1).lastObject];
        [self._io__raw_granules1 addObject:io__raw_granules1];
        [self.granules1 addObject:[granule_basic_dsk_rsdos_t initialize:io__raw_granules1 withStruct:self withRoot:self._root]];
    }
    self.reserved1 = [self._io read_bytes:256];
    self._raw_fat = [self._io read_bytes:256];
    self._io__raw_fat = [kstream streamWithData:self._raw_fat];
    self.fat = [file_allocation_table_basic_dsk_rsdos_t initialize:self._io__raw_fat withStruct:self withRoot:self._root];
    NSUInteger l_files = 72;
    self.files = [NSMutableArray arrayWithCapacity:l_files];
    for(int i = 0; i < l_files; i++)
    {
        [self.files addObject:[file_basic_dsk_rsdos_t initialize:self._io withStruct:self withRoot:self._root]];
    }
    self.reserved2 = [self._io read_bytes:(7 * 256)];

    self._raw_granules2 = [NSMutableArray array];
    self._io__raw_granules2 = [NSMutableArray array];
    self.granules2 = [NSMutableArray array];
    {
        int i=0;
        while (!self._io.eof) {
            @try {
                [self._raw_granules2 addObject:[self._io read_bytes:((9 * 256))]];
            } @catch (NSException *exception) {
                [NSException raise:exception.name format:@"%@: failed to create index: %d of granules2", exception.name, i];
            }

            kstream *io__raw_granules2 = [kstream streamWithData:(self._raw_granules2).lastObject];
            [self._io__raw_granules2 addObject:io__raw_granules2];
            [self.granules2 addObject:[granule_basic_dsk_rsdos_t initialize:io__raw_granules2 withStruct:self withRoot:self._root]];
            i++;
        }
    }
}

@end

@implementation granule_basic_dsk_rsdos_t

@dynamic _root;
@dynamic _parent;

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root
{
    return [[granule_basic_dsk_rsdos_t alloc] initWith:p__io withStruct:p__parent withRoot:p__root];
}

+ (instancetype) structWith:(kstream *)stream
{
    return [[granule_basic_dsk_rsdos_t alloc] initWith:stream withStruct:nil withRoot:nil];
}

- (instancetype) initWith:(kstream *)p__io withStruct:(basic_dsk_rsdos_t *)p__parent withRoot:(basic_dsk_rsdos_t *)p__root
{
    self = [super initWith:p__io withStruct:p__parent withRoot:p__root];
    if (self) {
        [self _read];
    }
    return self;
}

-(void)_read
{
    self.bytes = [self._io read_bytes:(9*256)];
}

@end

@implementation file_allocation_table_basic_dsk_rsdos_t

@dynamic _root;
@dynamic _parent;

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root
{
    return [[file_allocation_table_basic_dsk_rsdos_t alloc] initWith:p__io withStruct:p__parent withRoot:p__root];
}

+ (instancetype) structWith:(kstream *)stream
{
    return [[file_allocation_table_basic_dsk_rsdos_t alloc] initWith:stream withStruct:nil withRoot:nil];
}

- (instancetype) initWith:(kstream *)p__io withStruct:(basic_dsk_rsdos_t *)p__parent withRoot:(basic_dsk_rsdos_t *)p__root
{
    self = [super initWith:p__io withStruct:p__parent withRoot:p__root];
    if (self) {
        [self _read];
    }
    return self;
}

-(void)_read
{
    NSUInteger l_table = 68;
    self.table = [NSMutableArray arrayWithCapacity:l_table];
    for ( int i=0; i < l_table; i++)
    {
        [self.table addObject:(self._io).read_u1];
    }
    self.reserved = [self._io read_bytes:188];
}

@end

@implementation file_basic_dsk_rsdos_t

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root
{
    return [[file_basic_dsk_rsdos_t alloc] initWith:p__io withStruct:p__parent withRoot:p__root];
}

+ (instancetype) structWith:(kstream *)stream
{
    return [[file_basic_dsk_rsdos_t alloc] initWith:stream withStruct:nil withRoot:nil];
}

- (instancetype) initWith:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot:(kstruct *)p__root
{
    self = [super initWith:p__io withStruct:p__parent withRoot:p__root];
    if (self) {
        [self _read];
    }
    return self;
}

-(void)_read
{
    self.name = [[[[self._io read_bytes:8] KSBytesStripRightPadByte:32] KSBytesTerminateTerm:32 include:NO] ksBytesToStringWithEncoding:@"ASCII"];
    self.extension = [[[[self._io read_bytes:3] KSBytesStripRightPadByte:32] KSBytesTerminateTerm:32 include:NO] ksBytesToStringWithEncoding:@"ASCII"];
    self.file_type = [(self._io).read_u1 ksENUMWithDictionary:(self._root._enumerations)[@"FILE_TYPE"]];
    self.ascii_flag = [(self._io).read_u1 ksENUMWithDictionary:(self._root._enumerations)[@"ASCII_FLAG"]];
    self.ofs_granule = [granule_ptr_basic_dsk_rsdos_t initialize:self._io withStruct:self withRoot:self._root];
    self.bytes_in_last_sector = (self._io).read_u2be;
    self.reserved = [self._io read_bytes:16];
}

@end

@implementation granule_ptr_basic_dsk_rsdos_t

@dynamic _root;
@dynamic _parent;
@dynamic body;
@dynamic next;

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root
{
    return [[granule_ptr_basic_dsk_rsdos_t alloc] initWith:p__io withStruct:p__parent withRoot:p__root];
}

+ (instancetype) structWith:(kstream *)stream
{
    return [[granule_ptr_basic_dsk_rsdos_t alloc] initWith:stream withStruct:nil withRoot:nil];
}

- (instancetype) initWith:(kstream *)p__io withStruct:(file_basic_dsk_rsdos_t *)p__parent withRoot:(basic_dsk_rsdos_t *)p__root
{
    self = [super initWith:p__io withStruct:p__parent withRoot:p__root];
    if (self) {
        [self _read];
    }
    return self;
}

-(void)_read
{
    self.current_ptr = (self._io).read_u1;
}

-(NSData *)body
{
    if(_body) return _body;
    
    if (self.current_ptr.intValue < 68) {
        kstream *io = (self.current_ptr.intValue < 34) ? (self._root.granules1)[self.current_ptr.intValue]._io : ((self._root.granules2)[self.current_ptr.intValue - 34]._io);
        [io seek:0];
        _body = [io read_bytes:self._root.fat.table[self.current_ptr.intValue & 192].intValue == 0 ? ((9 * 256)) : ((self._root.fat.table[self.current_ptr.intValue].intValue & 63) - 1) * 256 + self._parent.bytes_in_last_sector.intValue];
    }
    
    return _body;
}

-(granule_ptr_basic_dsk_rsdos_t *)next
{
    if (_next) return _next;
    
    if (self.current_ptr.intValue < 68) {
        kstream *io = self._root.fat._io;
        unsigned long long pos = io.pos;
        [io seek:self.current_ptr.intValue];
        _next = [granule_ptr_basic_dsk_rsdos_t initialize:io withStruct:self._parent withRoot:self._root];
        [io seek:pos];
    }
    
    return _next;
}

@end
