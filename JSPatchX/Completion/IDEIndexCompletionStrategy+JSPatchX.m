//
//  IDEIndexCompletionStrategy+JSPatchX.m
//  JSPatchX
//
//  Created by bang on 4/7/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "IDEIndexCompletionStrategy+JSPatchX.h"
#import "MethodSwizzle.h"
#import "IDEIndex.h"
#import "IDEIndexSymbolOccurrenceCollection.h"
#import "IDEIndexSymbolWithOccurrenceCollection.h"
#import "IDEIndexCallableSymbol.h"
#import "IDEIndexCategorySymbol.h"
#import "DVTFilePath.h"
#import "DVTSourceCodeLanguage.h"
#import "IDEWorkspaceSettings.h"
#import "IDEWorkspaceArena.h"
#import "IDEWorkspaceArenaInfo.h"
#import "IDEIndexFileCollection.h"
#import "IDEIndexClassSymbol.h"
#import "IDEEditorDocument.h"
#import "DVTTextDocumentLocation.h"
#import "DVTSourceCodeLanguage.h"
#import "DVTSourceTextView.h"
#import "DVTCompletingTextView.h"
#import "DVTSourceCodeSymbolKind.h"
#import "JPCompletionItem.h"
#import "IDEWorkspace+JSPatchX.h"

@implementation IDEIndexCompletionStrategy (JSPatchX)

+ (void)load
{
    SWIZZLE(completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:);
}

- (id)swizzle_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 highlyLikelyCompletionItems:(id *)arg3 areDefinitive:(char *)arg4
{
    DVTSourceTextView* sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
    DVTTextStorage *textStorage= [arg2 objectForKey:@"DVTTextCompletionContextTextStorage"];
    DVTTextDocumentLocation *location = (DVTTextDocumentLocation *)arg1;
    IDEWorkspace *workspace = [arg2 objectForKey:@"IDETextCompletionContextWorkspaceKey"];
    IDEEditorDocument *document = [arg2 objectForKey:@"IDETextCompletionContextDocumentKey"];
    
    if (textStorage && [[document.filePath.pathString lowercaseString] hasSuffix:@".js"]) {
        return [self genCompletionItems:sourceTextView loc:location workSpace:workspace strFilePath:document.filePath.pathString];
    }else{
        return [self swizzle_completionItemsForDocumentLocation:arg1 context:arg2 highlyLikelyCompletionItems:arg3 areDefinitive:arg4];
    }
}

- (NSArray *)genCompletionItems:(DVTSourceTextView *)txtView loc:(DVTTextDocumentLocation *)location workSpace:(IDEWorkspace *)wspace strFilePath:(NSString *)filePath
{
    
    NSDictionary *itemsDict = [wspace.jsIndex completionItemsInProject];
    NSInteger loc = location.characterRange.location - 1;
    if (loc >= 0) {
        NSString *prevChar = [txtView.textStorage.string substringWithRange:NSMakeRange(loc,1)];
        if ([prevChar isEqualToString:@"."]) {
            return itemsDict[@"methods"];
        }
    }
    NSArray *keywordItems = [wspace.jsIndex keywordCompletionItemsWithFilePath:filePath];
    return [itemsDict[@"keywords"] arrayByAddingObjectsFromArray:keywordItems];
}

@end
