//
//  DVTTextCompletionSession+JSPatchX.m
//  JSPatchX
//
//  Created by louis on 4/7/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "DVTTextCompletionSession+JSPatchX.h"
#import "MethodSwizzle.h"
#import "DVTTextCompletionListWindowController.h"
#import "DVTTextCompletionInlinePreviewController.h"
#import "DVTSourceCodeLanguage.h"
#import "DVTSourceTextView.h"
#import "DVTSourceModel.h"
#import <objc/runtime.h>
#import "JPCompletionItem.h"
#import "JPCompletionItem.h"

@implementation DVTTextCompletionSession (JSPatchX)

+ (void)load
{
    SWIZZLE(_setFilteringPrefix:forceFilter:);
    SWIZZLE(initWithTextView:atLocation:cursorLocation:);
}

- (void)swizzle__setFilteringPrefix:(id)arg1 forceFilter:(BOOL)arg2
{
    BOOL isJS = [objc_getAssociatedObject(self, @"isJS") boolValue] ;
    if (!isJS) {
        [self swizzle__setFilteringPrefix:arg1 forceFilter:arg2];
        return;
    }
    NSString *comparePrefix = [arg1 lowercaseString];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    @try {
        for (JPCompletionItem * compitem in self.allCompletions) {
            if ([compitem.lowercaseName hasPrefix:comparePrefix]) {
                [arr addObject:compitem];
            }
        }
        
        if (0 == arr.count) {
            [self swizzle__setFilteringPrefix:arg1 forceFilter:arg2];
            return;
        }
    }@catch(NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    
    @try {
        
        [self willChangeValueForKey:@"filteredCompletionsAlpha"];
        [self willChangeValueForKey:@"selectedCompletionIndex"];
        
        [self setValue: arr forKey: @"_filteredCompletionsAlpha"];
        [self setValue: @(0) forKey: @"_selectedCompletionIndex"];
        
        [self didChangeValueForKey:@"filteredCompletionsAlpha"];
        [self didChangeValueForKey:@"selectedCompletionIndex"];
        
    }@catch(NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

- (id)swizzle_initWithTextView:(id)arg1 atLocation:(unsigned long long)arg2 cursorLocation:(unsigned long long)arg3
{
    DVTSourceTextView *txtView = (DVTSourceTextView *)arg1;
    if ([[txtView.textStorage.language.identifier lowercaseString] hasSuffix:@".javascript"]) {
        objc_setAssociatedObject(self, @"isJS", @(YES), OBJC_ASSOCIATION_ASSIGN);
    }else{
        objc_setAssociatedObject(self, @"isJS", @(NO), OBJC_ASSOCIATION_ASSIGN);
    }
    
    id obj = [self swizzle_initWithTextView:arg1 atLocation:arg2 cursorLocation:arg3];
    return obj;
}

- (BOOL)isJSSession
{
    return [objc_getAssociatedObject(self, @"isJS") boolValue];
}
@end
