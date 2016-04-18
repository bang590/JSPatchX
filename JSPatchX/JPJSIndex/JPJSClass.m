//
//  JPJSClass.m
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPJSClass.h"
#import "JPCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"

@implementation JPJSClass {
    NSString *_cls;
    NSString *_baseCls;
    NSArray *_properties;
}

- (instancetype)initWithClass:(NSString *)cls baseClass:(NSString *)baseCls properties:(NSArray *)properties
{
    self = [super init];
    if (self) {
        _cls = cls;
        _baseCls = baseCls;
        _properties = properties;
    }
    return self;
}

- (NSArray *)classCompletionItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (_cls) {
        JPCompletionItem *clsCompletionItem = [[JPCompletionItem alloc] initWithDictinary:@{
                                                kJPCompeletionName: _cls,
                                                kJPCompeletionDisplayText: _cls,
                                                kJPCompeletionText: _cls,
                                                kJPCompeletionDisplayType: @"Class",
                                                kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                                }];
        [items addObject:clsCompletionItem];
    }
    
    if (_baseCls) {
        JPCompletionItem *baseClsCompletionItem = [[JPCompletionItem alloc] initWithDictinary:@{
                                                kJPCompeletionName: _baseCls,
                                                kJPCompeletionDisplayText: _baseCls,
                                                kJPCompeletionText: _baseCls,
                                                kJPCompeletionDisplayType: @"Class",
                                                kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                                }];
        [items addObject:baseClsCompletionItem];
    }
    
    return items;
}

- (NSArray *)propertyCompletionItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *prop in _properties) {
        JPCompletionItem *item = [[JPCompletionItem alloc] initWithDictinary:@{
                                   kJPCompeletionName: prop,
                                   kJPCompeletionDisplayText: [NSString stringWithFormat:@"%@()", prop],
                                   kJPCompeletionText: [NSString stringWithFormat:@"%@()", prop],
                                   kJPCompeletionDisplayType: @"Property",
                                   kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                  }];
        [items addObject:item];
        
        if (prop.length > 1) {
            NSString *setName = [NSString stringWithFormat:@"set%@%@", [[prop substringToIndex:1] uppercaseString], [prop substringFromIndex:1]];
            JPCompletionItem *itemSet = [[JPCompletionItem alloc] initWithDictinary:@{
                                          kJPCompeletionName: [NSString stringWithFormat:@"%@()", setName],
                                          kJPCompeletionDisplayText: [NSString stringWithFormat:@"%@( val )", setName],
                                          kJPCompeletionText: [NSString stringWithFormat:@"%@(<# val #\>)", setName],
                                          kJPCompeletionDisplayType: @"property",
                                          kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                         }];
            [items addObject:itemSet];
        }
    }
    return items;
}
@end
