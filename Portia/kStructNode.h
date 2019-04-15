//
//  kStructNode.h
//  Portia
//
//  Created by tim lindner on 4/14/19.
//  Copyright © 2019 tim lindner. All rights reserved.
//

#ifndef kStructNode_h
#define kStructNode_h

#import <Cocoa/Cocoa.h>
#import "kaitaistruct.h"

// This is a simple wrapper around the Kaitai Struct. Its main purpose is to cache children fro display in a NSBrowser.
@interface kStructNode : NSObject <NSToolbarDelegate>
{
    NSString *_displayName;
}
// The designated initializer
- (id)initWithStruct:(id)inObject andName:(NSString *)inName NS_DESIGNATED_INITIALIZER;
- (id)nodeWithIndexPath:(NSIndexPath *)path;

@property(readonly, strong) id theObject;
@property(readonly, strong) NSString *displayName;
@property(readonly, strong) NSArray *children;
@property(readonly) BOOL isLeafItem;

@end
#endif /* kStructNode_h */
