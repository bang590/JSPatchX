//
//  JPCompletionItem.h
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright (c) 2016年 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEIndexCompletionItem.h"
#import "IDEIndexCallableSymbol.h"

const static NSString *kJPCompeletionName = @"kJPCName";
const static NSString *kJPCompeletionDisplayText = @"kJPCDplTxt";
const static NSString *kJPCompeletionDisplayType = @"kJPCDplType";
const static NSString *kJPCompeletionText = @"kJPCTxt";
const static NSString *kJPCompeletionKind = @"kJPCKind";

@interface JPCompletionItem : IDEIndexCompletionItem

- (instancetype)initWithDictinary:(NSDictionary *)dict;

- (NSString *)lowercaseName;

@end
