//
//  IDEEditorDocument+JSPatchX.m
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "IDEEditorDocument+JSPatchX.h"
#import "MethodSwizzle.h"
#import "DVTFilePath.h"

@implementation IDEEditorDocument (JSPatchX)

+(void)load
{
    SWIZZLE(ide_finishSaving:forSaveOperation:previousPath:);
}
- (void)swizzle_ide_finishSaving:(BOOL)arg1 forSaveOperation:(unsigned long long)arg2 previousPath:(id)arg3
{
    DVTFilePath *filePath = arg3;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JSPatchXFileSaved" object:filePath.pathString];
    [self swizzle_ide_finishSaving:arg1 forSaveOperation:arg2 previousPath:arg3];
}
@end
