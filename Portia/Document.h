//
//  Document.h
//  Portia
//
//  Created by tim lindner on 4/13/19.
//  Copyright © 2019 tim lindner. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "kaitaistruct.h"
#import "kStructNode.h"


@interface Document : NSPersistentDocument <NSBrowserDelegate>

-(IBAction)browserAction:(id)sender;

@property (weak) IBOutlet NSBrowser *browser;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property (strong) KSStruct *str;
@property (strong) kStructNode *rootNode;
@end
