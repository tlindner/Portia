#import "kaitaistruct.h"

#include <machine/endian.h>
#include <libkern/OSByteOrder.h>
#define bswap_16(x) OSSwapInt16(x)
#define bswap_32(x) OSSwapInt32(x)
#define bswap_64(x) OSSwapInt64(x)

uint64_t kaitai_kstream_get_mask_ones(unsigned long n);

@interface kstream ()

@property (readwrite) unsigned long long pos;
@property (readwrite) unsigned long long size;
@property (strong) NSFileHandle *fh;
@property (strong) NSData *dh;
@property NSUInteger m_bits_left;
@property NSUInteger m_bits;

@end

@implementation kstream
@dynamic pos;
@dynamic eof;

+ (kstream *)streamWithURL:(NSURL *)url
{
    NSError *myErr;
    NSFileHandle *io = [NSFileHandle fileHandleForReadingFromURL:url error: &myErr];
    
    if (io) {
        return [[kstream alloc] initWithFileHandle:io];
    }
    
    return nil;
}

+ (kstream *)streamWithFileHandle:(NSFileHandle *)io
{
	return [[kstream alloc] initWithFileHandle:io];
}

+ (kstream *)streamWithData:(NSData *)data
{
	return [[kstream alloc] initWithData:data];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self alignToByte];
    }
    
    return self;
}

- (kstream *)initWithFileHandle:(NSFileHandle *)io
{
	self.fh = io;
    self.size = [io seekToEndOfFile];
    [io seekToFileOffset:0];
    
	return [self init];
}

- (kstream *)initWithData:(NSData *)data
{
	self.dh = data;
    self.size = data.length;
    
	return [self init];
}

#pragma mark Stream positioning

- (unsigned long long)pos
{
    if (self.dh) {
        return _pos;
    }
    else {
        return self.fh.offsetInFile;
    }
}

-(void)setPos:(unsigned long long)p_pos
{
    [self seek:p_pos];
}

- (BOOL)isEof
{
    if (self.dh) {
        if (_pos >= self.size) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else
    {
        if (self.fh.offsetInFile >= self.size) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (void)seek:(unsigned long long)pos
{
    if (self.dh) {
        _pos = pos;
        
        if (_pos > self.size) _pos = self.size;
    } else {
        [self.fh seekToFileOffset:pos];
    }
}

#pragma mark Integer numbers

- (NSNumber *) read_s1
{
    char t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 1;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 1)];

    return [NSNumber numberWithChar:t];
}

#pragma mark Big-endian

- (NSNumber *) read_s2be
{
    int16_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 2;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 2)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_16(t);
#endif

    return [NSNumber numberWithShort:t];
}

- (NSNumber *) read_s4be
{
    int32_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 4;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 4)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_32(t);
#endif

    return [NSNumber numberWithInteger:t];
}

- (NSNumber *) read_s8be
{
    int64_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 8;
    } else {
        v_pos = 0;
    }

    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 8)];
    

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_64(t);
#endif
    
    return [NSNumber numberWithLongLong:t];
}

#pragma mark Little-endian
- (NSNumber *) read_s2le
{
    int16_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 2;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 2)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_16(t);
#endif

    return [NSNumber numberWithShort:t];
}

- (NSNumber *) read_s4le
{
    int32_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 4;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 4)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_32(t);
#endif

    return [NSNumber numberWithInteger:t];
}

- (NSNumber *) read_s8le
{
    int64_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 8;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 8)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_64(t);
#endif

    return [NSNumber numberWithLongLong:t];
}

#pragma mark Unsigned

- (NSNumber *) read_u1
{
    unsigned char t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 1;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 1)];

    return [NSNumber numberWithUnsignedChar:t];
}

#pragma mark Big-endian

- (NSNumber *) read_u2be
{
    uint16_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 2;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 2)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_16(t);
#endif

    return [NSNumber numberWithUnsignedShort:t];
}

- (NSNumber *) read_u4be
{
    uint32_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 4;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 4)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_32(t);
#endif

    return [NSNumber numberWithUnsignedInteger:t];
}

- (NSNumber *) read_u8be
{
    uint64_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 8;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 8)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_64(t);
#endif

    return [NSNumber numberWithUnsignedLongLong:t];
}

#pragma mark Little-endian

- (NSNumber *) read_u2le
{
    uint16_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 2;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 2)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_16(t);
#endif

    return [NSNumber numberWithUnsignedShort:t];
}

- (NSNumber *) read_u4le
{
    uint32_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 4;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 4)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_32(t);
#endif

    return [NSNumber numberWithUnsignedInteger:t];
}

- (NSNumber *) read_u8le
{
    uint64_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 8;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 8)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_64(t);
#endif

    return [NSNumber numberWithUnsignedLongLong:t];
}

#pragma mark Floating point numbers
#pragma mark Big-endian

- (NSNumber *) read_f4be
{
    uint32_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 4;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 4)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_32(t);
#endif

    float *f = (float *)&t;
    return [NSNumber numberWithFloat:*f];
}

- (NSNumber *) read_f8be
{
    uint64_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 8;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 8)];

#if __BYTE_ORDER == __LITTLE_ENDIAN
    t = bswap_64(t);
#endif
    
    double *d = (double *)&t;
    return [NSNumber numberWithDouble:*d];
}

#pragma mark Little-endian

- (NSNumber *) read_f4le
{
    uint32_t t;
    NSUInteger v_pos;

    if (self.dh) {
        v_pos = _pos;
        _pos += 4;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 4)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_32(t);
#endif

    float *f = (float *)&t;
    return [NSNumber numberWithFloat:*f];
}

- (NSNumber *) read_f8le
{
    uint64_t t;
    NSUInteger v_pos;
    
    if (self.dh) {
        v_pos = _pos;
        _pos += 8;
    } else {
        v_pos = 0;
    }
    
    [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&t range:NSMakeRange(v_pos, 8)];

#if __BYTE_ORDER == __BIG_ENDIAN
    t = bswap_64(t);
#endif

    double *d = (double *)&t;
    return [NSNumber numberWithDouble:*d];
}

#pragma mark Unaligned bit values

-(void)alignToByte
{
    self.m_bits_left = 0;
    self.m_bits = 0;
}

-(NSNumber *)read_bits_int:(NSUInteger)n
{
    unsigned long bits_needed = n - self.m_bits_left;
    if (bits_needed > 0) {
        // 1 bit  => 1 byte
        // 8 bits => 1 byte
        // 9 bits => 2 bytes
        unsigned long bytes_needed = ((bits_needed - 1) / 8) + 1;
        if (bytes_needed > 8) {
            NSException *myException = [NSException exceptionWithName:@"read_bits_int: more than 8 bytes requested" reason:nil userInfo:nil];
            @throw myException;
        }
        char *buf;
        NSUInteger v_pos;
        
        if (self.dh) {
            v_pos = _pos;
            _pos += bytes_needed;
        } else {
            v_pos = 0;
        }
        
        [(self.dh ? self.dh : [self.fh readDataOfLength:8]) getBytes:&buf range:NSMakeRange(v_pos, bytes_needed)];
        
        for (int i = 0; i < bytes_needed; i++) {
            uint8_t b = buf[i];
            self.m_bits <<= 8;
            self.m_bits |= b;
            self.m_bits_left += 8;
        }
    }
    
    // raw mask with required number of 1s, starting from lowest bit
    uint64_t mask = kaitai_kstream_get_mask_ones(n);
    // shift mask to align with highest bits available in @bits
    unsigned long shift_bits = self.m_bits_left - n;
    mask <<= shift_bits;
    // derive reading result
    uint64_t res = (self.m_bits & mask) >> shift_bits;
    // clear top bits that we've just read => AND with 1s
    self.m_bits_left -= n;
    mask = kaitai_kstream_get_mask_ones(self.m_bits_left);
    self.m_bits &= mask;
    
    return [NSNumber numberWithUnsignedLong:res];
}

#pragma mark Byte arrays

-(NSData *)read_bytes:(NSUInteger)len
{
    NSData *result;
    
    if (self.dh) {
        result = [self.dh subdataWithRange:NSMakeRange(_pos, len)];
        _pos += len;
    } else {
        result = [self.fh readDataOfLength:len];
    }

    [kstream throwIf:result smallerThan:len];
    
    return result;
}

-(NSData *)read_bytes_full
{
    NSData *result;
    
    if (self.dh) {
        NSRange range = NSMakeRange(_pos, self.size - _pos);
        result = [self.dh subdataWithRange:range];
        _pos = self.size;
    } else {
        result = [self.fh readDataToEndOfFile];
    }
    
    return result;
}

-(NSData *)read_bytes_term:(char)character include:(BOOL)include consume:(BOOL)consume eosErr:(BOOL)eos_error
{
    NSData *result;
    unsigned long long start = _pos;

    if (self.dh) {
        const char *buf = &(self.dh.bytes[_pos]);
        while( _pos < self.size )
        {
            if(buf[_pos++] == character) break;
        }
        
        if (_pos == self.size) {
            if (eos_error) {
                NSException *myException = [NSException exceptionWithName:@"read_bytes_term: encountered EOF" reason:nil userInfo:nil];
                @throw myException;
            }
        }

        NSRange range = NSMakeRange(start, start - _pos - (include ? 0 : 1));
        result = [self.dh subdataWithRange:range];

        if (!consume)
            _pos = _pos - 1;

    } else {
        NSMutableData *buffer = [NSMutableData data];
        NSData *temp;
        
        while((temp = [self.fh readDataOfLength:1]))
        {
            if (temp.length == 0) {
                if (eos_error) {
                    NSException *myException = [NSException exceptionWithName:@"read_bytes_term: encountered EOF" reason:nil userInfo:nil];
                    @throw myException;
                }
                break;
            }
            
            char t = ((char *)temp.bytes)[0];
            if (t == character) {
                if(include) [buffer appendData:temp];
                break;
            }
            
            [buffer appendData:temp];
        }

        if (!consume) [self.fh seekToFileOffset:self.fh.offsetInFile-1];

        result = [temp copy];
    }
    
    return result;
}

-(NSData *)ensure_fixed_contents:(NSData *)expected
{
    NSData *actual = [self read_bytes:[expected length]];
    
    if (![actual isEqualToData:expected]) {
        NSException *myException = [NSException exceptionWithName:@"ensure_fixed_contents: actual data does not match expected data" reason:nil userInfo:nil];
        @throw myException;
    }
    
    return actual;
}

+(NSData *)bytes_strip_right:(NSData *)src padByte:(unsigned char)pad_byte
{
    size_t new_len = src.length;
    char *src_ptr = (char *)[src bytes];
    
    while (new_len > 0 && src_ptr[new_len - 1] == pad_byte)
        new_len--;
    NSRange range = NSMakeRange(0, new_len);
    return [src subdataWithRange:range];
}

+(NSData *)bytes_terminate:(NSData *)src term:(char)term include:(BOOL)include;
{
    size_t new_len = 0;
    size_t max_len = src.length;
    char *src_ptr = (char *)[src bytes];
    
    while (new_len < max_len && src_ptr[new_len] != term)
        new_len++;
    
    if (include && new_len < max_len)
        new_len++;
    
    NSRange range = NSMakeRange(0, new_len);
    return [src subdataWithRange:range];
}

-(NSData *)process_xor_one:(NSData *)data withKey:(uint8_t)key
{
    size_t len = data.length;
    unsigned char *buf = malloc(len);
    
    if (!buf) {
        NSException *myException = [NSException exceptionWithName:@"process_xor_one: out of memory" reason:nil userInfo:nil];
        @throw myException;
    }
    
    unsigned char *src = (unsigned char *)data.bytes;

    for (size_t i = 0; i < len; i++)
        buf[i] = src[i] ^ key;
    
    return [NSData dataWithBytesNoCopy:buf length:len];
}

-(NSData *)process_xor_many:(NSData *)data withKey:(NSData *)key
{
    size_t len = data.length;
    size_t kl = key.length;
    unsigned char *data_buf = (unsigned char *)data.bytes;
    unsigned char *key_buf = (unsigned char *)key.bytes;

    unsigned char *buf = malloc(len);
    
    if (!buf) {
        NSException *myException = [NSException exceptionWithName:@"process_xor_many: out of memory" reason:nil userInfo:nil];
        @throw myException;
    }

    size_t ki = 0;
    for (size_t i = 0; i < len; i++) {
        buf[i] = data_buf[i] ^ key_buf[ki];
        ki++;
        if (ki >= kl)
            ki = 0;
    }
    
    return [NSData dataWithBytesNoCopy:buf length:len];
}

-(NSData *)process_rotate_left:(NSData *)data withAmount:(int)amount
{
    size_t len = data.length;
    unsigned char *buf = malloc(len);
    unsigned char *data_buf = (unsigned char *)data.bytes;

    if (!buf) {
        NSException *myException = [NSException exceptionWithName:@"process_rotate_left: out of memory" reason:nil userInfo:nil];
        @throw myException;
    }

    for (size_t i = 0; i < len; i++) {
        uint8_t bits = data_buf[i];
        buf[i] = (bits << amount) | (bits >> (8 - amount));
    }
    
    return [NSData dataWithBytesNoCopy:buf length:len];
}

#ifdef KS_ZLIB
#include <zlib.h>

-(NSData *)process_zlib(NSData *)data
{
    int ret;
    
    unsigned char *src_ptr = (unsigned char *)data.bytes;
    std::stringstream dst_strm;
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    
    ret = inflateInit(&strm);
    if (ret != Z_OK) {
        NSException *myException = [NSException exceptionWithName:@"process_zlib: inflateInit error" reason:nil userInfo:nil];
        @throw myException;
    }

    strm.next_in = src_ptr;
    strm.avail_in = data.length;
    
    unsigned char outbuffer[ZLIB_BUF_SIZE];
    NSMutabeData *outdata = [NSMutableData data];
    
    // get the decompressed bytes blockwise using repeated calls to inflate
    do {
        strm.next_out = outbuffer;
        strm.avail_out = sizeof(outbuffer);
        
        ret = inflate(&strm, 0);
        
        if (outdata.length < strm.total_out)
            [outdata appendData:[NSData dataWithBytes:outbuffer size:strm.total_out - outdata.length]]
    } while (ret == Z_OK);
    
    if (ret != Z_STREAM_END) {          // an error occurred that was not EOF
        NSException *myException = [NSException exceptionWithName:@"process_zlib: Z Lib error" reason:nil userInfo:nil];
        @throw myException;
    }
    
    if (inflateEnd(&strm) != Z_OK) {
        NSException *myException = [NSException exceptionWithName:@"process_zlib: inflateEnd error" reason:nil userInfo:nil];
        @throw myException;
    }
    
    return [outdata copy];
}

#endif

-(int) modA:(int)a b:(int)b;
{
    if (b <= 0)
        NSLog( @"Throw mod: divisor b <= 0");
    int r = a % b;
    if (r < 0)
        r += b;
    return r;
}

- (NSString *)to_string:(int)val
{
    return [NSString stringWithFormat:@"%d", val];
}

- (NSData *)reverse:(NSData *)val
{
    const char *bytes = [val bytes];
    
    NSUInteger datalength = [val length];
    
    char *reverseBytes = malloc(sizeof(char) * datalength);
    NSUInteger index = datalength - 1;
    
    for (int i = 0; i < datalength; i++)
        reverseBytes[index--] = bytes[i];

    return [NSData dataWithBytesNoCopy:reverseBytes length: datalength];
}

+(NSString *)bytes_to_str:(NSData *)src withEncoding:(NSString *)src_enc
{
    NSStringEncoding e = NSUTF8StringEncoding;
    NSString *lc_enc =[src_enc lowercaseString];
    
    if ([lc_enc isEqualToString:@"ascii"]) {
        e = NSMacOSRomanStringEncoding; /* OS X's ASCII is strictly 7 bit */
    } else if ([lc_enc isEqualToString:@"utf-8"]) {
        e = NSUTF8StringEncoding;
    } else if ([lc_enc isEqualToString:@"utf-16le"]) {
        e = NSUTF16LittleEndianStringEncoding;
    } else if ([lc_enc isEqualToString:@"utf-16be"]) {
        e = NSUTF16BigEndianStringEncoding;
    } else {
        NSLog( @"Throw unsupported string encoding" );
    }
    
    return [[NSString alloc] initWithData:src encoding:e];
}

+(NSDictionary *)dictionaryFor:(NSNumber *)number dictionary:(NSDictionary *)dictionary
{
    for (NSString *key in dictionary) {
        if ([[dictionary objectForKey:key] isEqualToNumber:number]) {
            return @{ key : number};
        }
    }
    
    return @{ @"Unknown type" : number };
}

+(void) throwIf:(NSData *)t smallerThan:(NSUInteger)v
{
    if (t.length < v) {
        NSException *myException = [NSException exceptionWithName:@"Read past EOF" reason:nil userInfo:nil];
        @throw myException;
    }
}

@end

@implementation kstruct

+ initialize:(kstream *)p__io
{
    return [[kstruct alloc] initWith:p__io withStruct:nil withRoot:nil];
}

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent
{
    return [[kstruct alloc] initWith:p__io withStruct:p__parent withRoot:nil];
}

+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root
{
    return [[kstruct alloc] initWith:p__io withStruct:p__parent withRoot:p__root];
}

- initWith:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: (kstruct *)p__root
{
    self = [super init];
    if (self) {
        self._io = p__io;
        self._root = p__root;
        self._parent = p__parent;
    }
    return self;
}

@end

uint64_t kaitai_kstream_get_mask_ones(unsigned long n) {
    if (n == 64) {
        return 0xFFFFFFFFFFFFFFFF;
    } else {
        return ((uint64_t) 1 << n) - 1;
    }
}

