//
//  JPObjcIndex.m
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPObjcIndex.h"
#import "IDEWorkspace+JSPatchX.h"
#import "IDEWorkspaceArena.h"
#import "DVTFilePath.h"
#import "JPCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"
#import "JPObjcFile.h"
#import "JPObjcMethod.h"
#import "JPObjcClass.h"
#import "JPObjcProtocol.h"

@implementation JPObjcIndex {
    /*
     { 
        "$clsname" : {
            "super": "$superClassName"j,
            "methods": [ $JPObjcMethod, ...]
        }, ...
     }
    */
    NSMutableDictionary *_parsedClassCache;
    NSMutableArray *_protocolCompletionItems;
    __weak IDEWorkspace *_workspace;
}

- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace
{
    self = [super init];
    if (self) {
        _workspace = workspace;
    }
    return self;
}

- (NSArray *)_superClassesOfClass:(NSString *)clsName
{
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    while (![clsName isEqualToString:@"NSObject"] && clsName) {
        if (_parsedClassCache[clsName]) {
            NSString *superClsName = _parsedClassCache[clsName][@"super"];
            if (superClsName.length) {
                [classes addObject:superClsName];
            }
            clsName = superClsName;
        } else {
            break;
        }
    }
    return classes;
}

- (NSArray *)_allClassesWithClasses:(NSArray *)classes
{
    NSMutableArray *allClasses = [[NSMutableArray alloc] init];
    for (NSString *clsName in classes) {
        NSArray *superClasses = [self _superClassesOfClass:clsName];
        for (NSString *superClsName in superClasses) {
            if (![allClasses containsObject:superClasses]) {
                [allClasses addObject:superClsName];
            }
        }
        if (![allClasses containsObject:clsName]) {
            [allClasses addObject:clsName];
        }
    }
    if (![allClasses containsObject:@"NSObject"]) {
        [allClasses addObject:@"NSObject"];
    }
    return allClasses;
}

- (NSArray *)_completionItemsWithClass:(NSString *)className
{
    @synchronized(self) {
        if (_parsedClassCache[className] && _parsedClassCache[className][@"methods"]) {
            NSArray *methods = _parsedClassCache[className][@"methods"];
            NSMutableArray *completionItems = [[NSMutableArray alloc] initWithCapacity:methods.count];
            for (JPObjcMethod *method in methods) {
                if (method.methodName.length == 0) {
                    continue;
                }
                [completionItems addObject:[method completionItem]];
            }
            return completionItems;
        }
    }
    return nil;
}

- (NSArray *)methodCompletionItemsWithClasses:(NSArray *)classes
{
    @synchronized(self) {
        if (!_parsedClassCache) {
            _parsedClassCache = [[NSMutableDictionary alloc] init];
            _protocolCompletionItems = [[NSMutableArray alloc] init];
            [self _scanProjectHeaders];
            [self _scanDefaultFramework];
        }
    }
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSArray *allClasses = [self _allClassesWithClasses:classes];
    for (NSString *clsName in allClasses) {
        [ret addObjectsFromArray:[self _completionItemsWithClass:clsName]];
    }
    
    return ret;
}

- (NSArray *)protocolCompletionItems
{
    @synchronized (self) {
        return _protocolCompletionItems;
    }
}

- (void)_scanProjectHeaders
{
    NSString *folder = [_workspace currentProjectFolder];
    NSArray *fileList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folder error:nil];
    for (NSString *file in fileList) {
        if ([file hasSuffix:@".h"]) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", folder, file];
            [self _parseFile:filePath];
        }
    }
}

-(void)_scanDefaultFramework
{
    NSArray *arrDirs = [_workspace defaultScanHeaderDirs];
    for (NSString *dir in arrDirs) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            continue;
        }
        NSArray *headers = [[NSFileManager defaultManager] subpathsAtPath:dir];
        for (NSString *header in headers) {
            if ([header hasSuffix:@".h"] || [header hasSuffix:@".H"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", dir, header];
                [self _parseFile:filePath];
            }
        }
    }
}

- (void)_parseFile:(NSString *)filePath
{
    JPObjcFile *objcFile = [JPObjcFile parseFile:filePath];
    if (objcFile && objcFile.classes) {
        @synchronized(self) {
            for (JPObjcClass *objcCls in objcFile.classes) {
                if (!objcCls.methods.count) continue;
                if (!_parsedClassCache[objcCls.clsName]) {
                    _parsedClassCache[objcCls.clsName] = [[NSMutableDictionary alloc] init];
                }
                NSMutableArray *methods = _parsedClassCache[objcCls.clsName][@"methods"];
                if (methods && [methods isKindOfClass:[NSMutableArray class]]) {
                    [methods addObjectsFromArray:objcCls.methods];
                } else {
                    [_parsedClassCache[objcCls.clsName] setObject:[objcCls.methods mutableCopy] forKey:@"methods"];
                }
                if (!_parsedClassCache[objcCls.clsName][@"super"] && objcCls.superClsName.length) {
                    [_parsedClassCache[objcCls.clsName] setObject:objcCls.superClsName forKey:@"super"];
                }
            }
            for (JPObjcProtocol *prop in objcFile.protocols) {
                [_protocolCompletionItems addObjectsFromArray:prop.methodCompletionItems];
            }
        }
    }
}

@end
