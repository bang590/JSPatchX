//
//  JPCompletionItem.m
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright (c) 2016年 bang. All rights reserved.
//

#import "JPCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"
#import "DVTSourceCodeLanguage.h"
#import "IDEIndexCollection.h"
#import "IDEIndexSymbolCollection.h"

@implementation JPCompletionItem {
    NSDictionary *_dict;
    NSString *_lowercasename;
}

-(instancetype)initWithDictinary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}

- (NSString *)name
{
    return [_dict objectForKey:kJPCompeletionName];
}

- (NSString *)displayText
{
    return [_dict objectForKey:kJPCompeletionDisplayText];
}

- (NSString *)displayType
{
    return [_dict objectForKey:kJPCompeletionDisplayType];
}

- (NSString *)completionText
{
    return [_dict objectForKey:kJPCompeletionText];
}

- (void)_fillInTheRest { }

- (double)priority
{
    return 9999;
}

- (DVTSourceCodeSymbolKind *)symbolKind
{
    return [_dict objectForKey:kJPCompeletionKind];
}

- (BOOL)notRecommended
{
    return NO;
}

- (NSString *)lowercaseName {
    if (!_lowercasename) {
        _lowercasename = [self.name lowercaseString];
    }
    return _lowercasename;
}

@end
