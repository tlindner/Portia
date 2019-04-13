#ifndef KAITAI_STRUCT_H
#define KAITAI_STRUCT_H

#import <Cocoa/Cocoa.h>
#import "kaitaistream.h"

@interface kstruct : NSObject
{
    NSDictionary *_enumerations;
}

+ initialize:(kstream *)p__io;
+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent;
+ initialize:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: p__root;

- initWith:(kstream *)p__io withStruct:(kstruct *)p__parent withRoot: (kstruct *)p__root;

@property (strong) kstream *_io;
@property (strong) kstruct *_parent;
@property (strong) kstruct *_root;

@property (strong, readonly) NSDictionary* enumerations;

@end


#endif
