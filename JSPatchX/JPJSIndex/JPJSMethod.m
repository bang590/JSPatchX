//
//  JPJSMethod.m
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPJSMethod.h"
#import "DVTSourceCodeSymbolKind.h"

@implementation JPJSMethod {
    NSString *_name;
    NSArray *_params;
}
- (instancetype)initWithMethodName:(NSString *)name params:(NSArray *)params
{
    self = [super init];
    if (self) {
        _name = name;
        _params = params;
    }
    return self;
}


- (NSString *)displayText
{
    NSMutableString *str = [_name mutableCopy];
    [str appendString:@"("];
    for (NSString *param in _params) {
        [str appendFormat:@"%@, ", param];
    }
    if (_params.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 2, 2)];
    }
    [str appendString:@")"];
    return str;
}

- (NSString *)completionText
{
    NSMutableString *str = [_name mutableCopy];
    [str appendString:@"("];
    for (NSString *param in _params) {
        [str appendFormat:@"<#%@#\>, ", param];
    }
    if (_params.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 2, 2)];
    }
    [str appendString:@")"];
    return str;
}

- (JPCompletionItem *)completionItem
{
    JPCompletionItem *item = [[JPCompletionItem alloc] initWithDictinary:@{
                                  kJPCompeletionName: _name,
                                  kJPCompeletionDisplayText: [self displayText],
                                  kJPCompeletionText: [self completionText],
                                  kJPCompeletionDisplayType: @"function",
                                  kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                  }];
    return item;
}
@end
