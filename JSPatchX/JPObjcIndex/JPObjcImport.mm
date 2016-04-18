//
//  JPObjcImport.m
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "JPObjcImport.h"
#import "objcParser.h"

@implementation JPObjcImport 

-(instancetype)initWithParseResult:(void *)result{
    if (self = [super init]) {
        ImportSymbol *imps = (ImportSymbol *)result;
        _header = [NSString stringWithUTF8String:imps->path.c_str()];
        _isSys = imps->isSys != 0;
    }
    return self;
}

@end
