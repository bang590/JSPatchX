//
//  JPJSIndex.m
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPJSIndex.h"
#import "IDEWorkspace+JSPatchX.h"
#import "JPJSFile.h"
#import "JPCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"

@implementation JPJSIndex {
    __weak IDEWorkspace *_workspace;
    
    /*
     {
        "methods": [],
        "keywords": [],
     }
     */
    NSDictionary *_allCompletionItemsCache;
    NSArray *_keywordCompletionItemsCache;
    NSMutableDictionary *_jsFileCache;
}

- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace
{
    self = [super init];
    if (self) {
        _workspace = workspace;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFileSaved:) name:@"JSPatchXFileSaved" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)keywordCompletionItemsWithFilePath:(NSString *)filePath
{
    @synchronized(self) {
        if (_jsFileCache && _jsFileCache[filePath]) {
            JPJSFile *file = _jsFileCache[filePath];
            return file.keywordCompletionItems;
        }
        return nil;
    }
}

- (NSDictionary *)completionItemsInProject
{
    @synchronized(self) {
        if (!_jsFileCache) {
            _jsFileCache = [self _scanProjectJS];
        }
    
        if (!_allCompletionItemsCache) {
            NSMutableDictionary *completionItems = [[NSMutableDictionary alloc] init];
            [completionItems setObject:[[NSMutableArray alloc] init] forKey:@"methods"];
            [completionItems setObject:[[NSMutableArray alloc] init] forKey:@"keywords"];
            
            
            for (NSString *key in _jsFileCache) {
                JPJSFile *file = _jsFileCache[key];
                NSArray *ocMethodItems = [_workspace.objcIndex methodCompletionItemsWithClasses:file.requireClasses];
                [self _addItemsFrom:ocMethodItems to:completionItems[@"methods"]];
                [self _addItemsFrom:file.classCompletionItems to:completionItems[@"keywords"]];
                [self _addItemsFrom:file.methodCompletionItems to:completionItems[@"methods"]];
                [self _addItemsFrom:file.propertyCompletionItems to:completionItems[@"methods"]];
                
            }
            [self _addItemsFrom:[_workspace.objcIndex protocolCompletionItems] to:completionItems[@"methods"]];
            
            
            //keywordTemplate.plist
            if (!_keywordCompletionItemsCache) {
                NSMutableArray *items = [[NSMutableArray alloc] init];
                NSArray *symbols = [self _loadKeywordTemplates];
                for (int i = 0; i < symbols.count; ++i) {
                    NSDictionary *dict = [symbols objectAtIndex:i];
                    [items addObject:[[JPCompletionItem alloc] initWithDictinary:dict]];
                }
                _keywordCompletionItemsCache = items;
            }
            [self _addItemsFrom:_keywordCompletionItemsCache to:completionItems[@"keywords"]];
            
            
            _allCompletionItemsCache = completionItems;
        }
    }
    
    return _allCompletionItemsCache;
}


- (NSMutableDictionary *)_scanProjectJS
{
    NSMutableDictionary *fileCache = [[NSMutableDictionary alloc] init];
    
    NSString *folder = [_workspace currentProjectFolder];
    if (folder.length) {
        NSArray *fileList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folder error:nil];
        for (NSString *file in fileList) {
            if ([file hasSuffix:@".js"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", folder, file];
                NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                JPJSFile *file = [[JPJSFile alloc] initWithContent:content];
                [fileCache setObject:file forKey:filePath];
            }
        }
    }
    return fileCache;
}


-(NSArray *)_loadKeywordTemplates{
    NSString * fpath = [[NSBundle bundleForClass:[JPJSIndex class]] pathForResource:@"keywordTemplate" ofType:@"plist"];
    NSDictionary *dc = [NSDictionary dictionaryWithContentsOfFile:fpath];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < dc.allValues.count; ++i) {
        NSDictionary *item = [dc.allValues objectAtIndex:i];
        NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [newItem setObject:[DVTSourceCodeSymbolKind classMethodTemplateSymbolKind] forKey:@"kJPCompeletionKind"];
        [arr addObject:newItem];
    }
    
    return arr;
}


- (void)handleFileSaved:(NSNotification *)notification
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self) {
            NSString *filePath = notification.object;
            if (_jsFileCache) {
                NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                JPJSFile *file = [[JPJSFile alloc] initWithContent:content];
                    [_jsFileCache setObject:file forKey:filePath];
            }
            if (_allCompletionItemsCache) {
                _allCompletionItemsCache = nil;
            }
        }
    });
}

- (void)_addItemsFrom:(NSArray *)fromItems to:(NSMutableArray *)toItems
{
    for (JPCompletionItem *fromItem in fromItems) {
        BOOL exist = NO;
        for (JPCompletionItem *toItem in toItems) {
            if ([toItem.name isEqualToString:fromItem.name]) {
                exist = YES;
                break;
            }
        }
        if (!exist) [toItems addObject:fromItem];
    }
}
@end
