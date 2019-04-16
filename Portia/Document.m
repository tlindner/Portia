//
//  Document.m
//  Portia
//
//  Created by tim lindner on 4/13/19.
//  Copyright © 2019 tim lindner. All rights reserved.
//

#import "Document.h"
#import "kaitaistream.h"
#import "basic_dsk_rsdos.h"
#import "PropertyUtil.h"

NSString * NSDataToHex(NSData *data);

@interface Document ()

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.

        NSURL *fu = [NSURL fileURLWithPath:@"/Users/tlindner/Public/mame/SSC.dsk"];
        kstream *s = [kstream streamWithURL:fu];
        @try {
            self.str = [basic_dsk_rsdos_t structWith:s];

        } @catch (NSException *exception) {
            NSLog( @"exception: %@", exception );
            [self.textView setString:[exception description]];
        }
    }
    
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

#pragma mark - NSBrowserDelegate

-(IBAction)browserAction:(NSBrowser *)sender
{
    for (int i =1 ; i < sender.lastVisibleColumn; i++) {
        [sender setWidth:sender.defaultColumnWidth ofColumn:1];
    }
    
    id object;
    NSString *result;

    @try {
        object = [[self.rootNode nodeWithIndexPath:sender.selectionIndexPath] theObject];

        if (!object) {
            result = @"";
        } else if ([[object class] isSubclassOfClass:[NSString class]]) {
            result = [object description];
        } else if ([[object class] isSubclassOfClass:[NSDictionary class]]) {
            result = [object description];
        } else if ([[object class] isSubclassOfClass:[NSNumber class]]) {
            result = [object description];
        } else if ([[object class] isSubclassOfClass:[NSData class]]) {
            result = NSDataToHex(object);
        } else { /* kstruct class, NSArray */
            result = [object description];
        }
    } @catch (NSException *exception) {
        result = [NSString stringWithFormat:@"Exception: %@", [exception description]];
    }
    
    
    [self.textView setString:result];
}

-(void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    int colWidth = [sender frameOfColumn:column].size.width;
    
    if ([cell cellSize].width + 15 > colWidth) {
        CGSize theSize = [cell cellSize];
        theSize.width += 15;
        [sender setWidth:theSize.width ofColumn:column];
    }
}

- (id)rootItemForBrowser:(NSBrowser *)browser {
    
    if (self.rootNode == nil) {
        _rootNode = [[kStructNode alloc] initWithStruct:self.str andName:@"root"];
    }
    return self.rootNode;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    kStructNode *node = (kStructNode *)item;
    return node.children.count;
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    kStructNode *node = (kStructNode *)item;
    return [node.children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    kStructNode *node = (kStructNode *)item;
    return node.isLeafItem;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    kStructNode *node = (kStructNode *)item;
    return node.displayName;
}

@end

NSString * NSDataToHex(NSData *data) {
    NSUInteger len, malloc_length;
    int i, j, ptr = 0;
    char *buf, *bytes;
    
    len = data.length;
    bytes = (char*)data.bytes;
    malloc_length = ((len / 16) + 1) * (5 + (5*8) + 2 + (1 * 16) + 1);
    
    buf = malloc(malloc_length + 1);
    
    for (i=0; i<len && ptr < malloc_length; i = i + 16) {
        ptr += sprintf(&(buf[ptr]), "%4.4x ", i );
        
        for (j=0; j<16 && i+j<len && ptr < malloc_length; j += 2) {
            ptr += sprintf(&(buf[ptr]), "%2.2x%2.2x ", bytes[i+j], bytes[i+j+1]);
        }
        
        for (; j<16 && ptr < malloc_length; j += 2) {
            ptr += sprintf(&(buf[ptr]), "     ");
        }
        
        ptr += sprintf(&(buf[ptr]), "  " );
 
        for (j=0; j<16 && i+j<len && ptr < malloc_length; j++) {
            ptr += sprintf(&(buf[ptr]), "%c", isprint(bytes[i+j]) ? bytes[i+j] : '.' );
        }
        
        ptr += sprintf(&(buf[ptr]), "\r" );
     }
    
    NSString *result = [[NSString alloc] initWithBytes:buf length:malloc_length encoding:NSASCIIStringEncoding];
    free(buf);
    
    return result;
}
