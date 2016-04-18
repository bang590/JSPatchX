//
//  DVTTextCompletionDataSource+JSPatchX.m
//  JSPatchX
//
//  Created by bang on 4/7/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "DVTTextCompletionDataSource+JSPatchX.h"
#import "MethodSwizzle.h"
#import "DVTSourceCodeLanguage.h"
#import "IDEIndexCompletionStrategy.h"

@implementation DVTTextCompletionDataSource (JSPatchX)

+ (void)load
{
    SWIZZLE(strategies);
}

- (NSArray*)swizzle_strategies
{
    if ([[self.language.identifier lowercaseString] hasSuffix:@".javascript"]) {
        return [NSArray arrayWithObject:[[IDEIndexCompletionStrategy alloc] init]];
    }else{
        return [self swizzle_strategies];
    }
}


@end
