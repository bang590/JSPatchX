//
//  JPObjcArg.m
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "JPObjcArg.h"
#import "objcParser.h"
#import "NSString+JSPatchX.h"

@implementation JPObjcArg 

- (instancetype)initWithParseResult:(void *)result
{
    if (self = [super init]) {
        ArgSymbol * argsym = (ArgSymbol *)result;
        _selector = [NSString stringWithUTF8String:argsym->selector.c_str()];
        _argName  = [[NSString stringWithUTF8String:argsym->argName.c_str()] trim];
        _argType  = [[NSString stringWithUTF8String:argsym->argType.c_str()] trim];
    }
    return self;
}


@end
