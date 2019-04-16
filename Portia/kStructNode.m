//
//  kStructNode.m
//  Portia
//
//  Created by tim lindner on 4/14/19.
//  Copyright © 2019 tim lindner. All rights reserved.
//

#import "kStructNode.h"
#import "PropertyUtil.h"

@interface kStructNode ()

@property (assign) BOOL childrenDirty;
@property (strong) NSMutableDictionary *internalChildren;
@property(strong) NSString *displayName;
@end

#pragma mark -

@implementation kStructNode

@dynamic displayName, children, isLeafItem;

- (instancetype)init {
    
    NSAssert(NO, @"Invalid use of init; use initWithURL to create FileSystemNode");
    return [self init];
}

- (id)initWithStruct:(id)inObject andName:(NSString *)inName {
    self = [super init];
    if (self != nil) {
        _theObject = inObject;
        _displayName = inName;
    }
    return self;
}

- (id)nodeWithIndexPath:(NSIndexPath *)path
{
    if (path.length == 0) {
        return self;
    }
    
    NSUInteger *intPaths = malloc(sizeof(NSUInteger) * path.length);
    [path getIndexes:intPaths range:NSMakeRange(0, path.length)];
    NSIndexPath *ip = [[NSIndexPath alloc] initWithIndexes:intPaths+1 length:path.length-1];
    id result = [self.children[intPaths[0]] nodeWithIndexPath:ip];
    free(intPaths);
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", super.description, self.displayName];
}

- (NSString *)displayName {
    NSString *displayName;
    
    if (!self.theObject) {
        displayName = [NSString stringWithFormat:@"%@: nil", _displayName];
    } else if ([[self.theObject class] isSubclassOfClass:[NSString class]]) {
            displayName = [NSString stringWithFormat:@"%@: %@", _displayName, self.theObject];
    } else if ([[self.theObject class] isSubclassOfClass:[NSDictionary class]]) {
        displayName = [NSString stringWithFormat:@"%@: %@, value: %@", _displayName, self.theObject[@"enum"], self.theObject[@"value"]];
    } else if ([[self.theObject class] isSubclassOfClass:[NSNumber class]]) {
        displayName = [NSString stringWithFormat:@"%@: %@", _displayName, [self.theObject stringValue]]; ;
    } else { /* kstruct class, NSArray, NSData */
        displayName = _displayName;
    }

    return displayName;
}

- (BOOL)isLeafItem {
    if (!self.theObject) {
        return YES;
    } else if ([[self.theObject class] isSubclassOfClass:[NSArray class]]) {
        return NO;
    } else if ([[self.theObject class] isSubclassOfClass:[NSData class]]) {
        return YES;
    } else if ([[self.theObject class] isSubclassOfClass:[NSString class]]) {
        return YES;
    } else if ([[self.theObject class] isSubclassOfClass:[NSDictionary class]]) {
        return YES;
    } else if ([[self.theObject class] isSubclassOfClass:[NSNumber class]]) {
        return YES;
    } else { /* kstruct class */
        return NO;
    }
}

- (NSArray *)children {
    if (self.internalChildren == nil || self.childrenDirty) {

        if (!self.theObject) {
            NSLog( @"Error, trying to get children of null" );
        }
        
        NSMutableDictionary *newChildren = [NSMutableDictionary new];
        
        if ([[self.theObject class] isSubclassOfClass:[NSArray class]]) {
            int i = 0;
            for (id object in self.theObject) {
                kStructNode *node = [[kStructNode alloc] initWithStruct:object andName:[NSString stringWithFormat:@"%d", i]];
                [newChildren setValue:node forKey:[NSString stringWithFormat:@"%d", i]];
                i++;
            }
        } else { /* kstruct class */
            for (NSString *property in [PropertyUtil classPropsFor:[self.theObject class]].allKeys) {
                SEL selector = NSSelectorFromString(property);
                IMP imp = [self.theObject methodForSelector:selector];
                id (*func)(id, SEL) = (void *)imp;
                id childObject = func(self.theObject, selector);
                
                    kStructNode *node = [[kStructNode alloc] initWithStruct:childObject andName:property];
                    [newChildren setValue:node forKey:property];
            }
        }

        self.internalChildren = newChildren;
        self.childrenDirty = NO;
    }

    NSArray *result = [self.internalChildren allValues];
    
    // Sort the children by the display name and return it
    result = [result sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSString *objName = [obj1 displayName];
        NSString *obj2Name = [obj2 displayName];
        NSComparisonResult sortedResult = [objName compare:obj2Name options:NSNumericSearch | NSCaseInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch range:NSMakeRange(0, [objName length]) locale:[NSLocale currentLocale]];
        return sortedResult;
    }];
    return result;
}

@end

