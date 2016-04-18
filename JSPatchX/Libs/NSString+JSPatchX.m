//
//  NSString+JSPatchX.m
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "NSString+JSPatchX.h"

@implementation NSString (JSPatchX)

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end