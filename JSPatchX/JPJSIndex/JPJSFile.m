//
//  JPJSFile.m
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPJSFile.h"
#import "JPJSMethod.h"
#import "JPJSClass.h"
#import "DVTSourceCodeSymbolKind.h"
#import "NSString+JSPatchX.h"

@implementation JPJSFile {
    NSArray *_requireClasses;
    NSMutableArray *_classCompletionItems;
    NSMutableArray *_methodCompletionItems;
    NSMutableArray *_propertyCompletionItems;
    
    NSArray *_keywords;
    NSMutableArray *_keywordCompletionItems;
}

static NSString *_regexRequireStr = @"require\\([\\\'\\\"](.+)[\\\'\\\"]\\)";
static NSString *_regexDefineStr = @"(defineClass|defineJSClass)\\([\\\'\\\"](.|\\n)+?\\{";
static NSString *_regexMethodStr = @".+\\s*:\\s*function\\s*\\(.*\\)";
static NSString *_regexKeywordStr = @"([a-zA-Z]|_|$){1}\\w*";

static NSRegularExpression* _regexRequire;
static NSRegularExpression* _regexDefine;
static NSRegularExpression* _regexMethod;
static NSRegularExpression* _regexKeyword;
- (instancetype)initWithContent:(NSString *)content
{
    self = [super init];
    if (self) {
        if (!_regexRequire) {
            _regexRequire = [NSRegularExpression regularExpressionWithPattern:_regexRequireStr options:0 error:nil];
        }
        if (!_regexDefine) {
            _regexDefine = [NSRegularExpression regularExpressionWithPattern:_regexDefineStr options:0 error:nil];
        }
        if (!_regexMethod) {
            _regexMethod = [NSRegularExpression regularExpressionWithPattern:_regexMethodStr options:0 error:nil];
        }
        if (!_regexKeyword) {
            _regexKeyword = [NSRegularExpression regularExpressionWithPattern:_regexKeywordStr options:0 error:nil];
        }
        _requireClasses = [self _requireClassesWithContent:content];
        
        _classCompletionItems = [[NSMutableArray alloc] init];
        _propertyCompletionItems = [[NSMutableArray alloc] init];
        NSArray *classes = [self _defineClassesWithContent:content];
        for (JPJSClass *cls in classes) {
            NSArray *items = [cls classCompletionItems];
            if (items) {
                [_classCompletionItems addObjectsFromArray:items];
            }
            NSArray *propItems = [cls propertyCompletionItems];
            if (propItems) {
                [_propertyCompletionItems addObjectsFromArray:propItems];
            }
        }
        [_classCompletionItems addObjectsFromArray:[self _completionItemsWithRequireClasses:_requireClasses]];
        
        _methodCompletionItems = [[NSMutableArray alloc] init];
        NSArray *methods = [self _methodsWithContent:content];
        for (JPJSMethod *method in methods) {
            JPCompletionItem *item = method.completionItem;
            if (item) {
                [_methodCompletionItems addObject:method.completionItem];
            }
        }
        
        _keywords = [self _keywordsWithContent:content];
    }
    return self;
}

- (NSArray *)_completionItemsWithRequireClasses:(NSArray *)classes
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *className in classes) {
        JPCompletionItem *clsCompletionItem = [[JPCompletionItem alloc] initWithDictinary:@{
                                                kJPCompeletionName: className,
                                                kJPCompeletionDisplayText: className,
                                                kJPCompeletionText: className,
                                                kJPCompeletionDisplayType: @"Class",
                                                kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                                }];
        [items addObject:clsCompletionItem];
    }
    return items;
}

- (NSArray *)_requireClassesWithContent:(NSString *)content
{
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    [_regexRequire enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *requireStr = [content substringWithRange:result.range];
            if (requireStr.length > 11) {
                NSString *clsNames = [requireStr substringWithRange:NSMakeRange(9, requireStr.length - 2 - 9)];
                NSArray *clsArr = [clsNames componentsSeparatedByString:@","];
                for (NSString *clsName in clsArr) {
                    NSString *clsNameTrim = [clsName trim];
                    if (![classes containsObject:clsNameTrim]) {
                        [classes addObject:clsNameTrim];
                    }
                }
            }
        }
    }];
    return classes;
}

- (NSArray *)_defineClassesWithContent:(NSString *)content
{
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    [_regexDefine enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *defineStr = [content substringWithRange:result.range];
            
            NSCharacterSet *quoteSet = [NSCharacterSet characterSetWithCharactersInString:@"\'\""];
            
            NSScanner *scanner = [NSScanner scannerWithString:defineStr];
            
            [scanner scanUpToCharactersFromSet:quoteSet intoString:nil];
            [scanner setScanLocation:[scanner scanLocation] + 1];
            NSString *clsDefineStr;
            [scanner scanUpToCharactersFromSet:quoteSet intoString:&clsDefineStr];
            
            
            NSString *baseClsName;
            NSString *clsName;
            if (clsDefineStr.length) {
                NSArray *clsDefineArr = [clsDefineStr componentsSeparatedByString:@":"];
                clsName = [clsDefineArr[0] trim];
                if (clsDefineArr.count > 1) {
                    baseClsName = [clsDefineArr[0] trim];
                }
            }
            
            NSMutableArray *properties = [[NSMutableArray alloc] init];
            [scanner setScanLocation:[scanner scanLocation] + 1];
            [scanner scanUpToString:@"[" intoString:nil];
            if (![scanner isAtEnd]) {
                [scanner setScanLocation:[scanner scanLocation] + 1];
                if (![scanner isAtEnd]) {
                    NSString *propertiesStr;
                    NSCharacterSet *trashSet = [NSCharacterSet characterSetWithCharactersInString:@"\'\"\r\n"];
                    [scanner scanUpToString:@"]" intoString:&propertiesStr];
                    NSArray *propertiesArr = [propertiesStr componentsSeparatedByString:@","];
                    for (NSString *prop in propertiesArr) {
                        NSString *trimProp = [[[prop componentsSeparatedByCharactersInSet:trashSet] componentsJoinedByString:@""] trim];
                        if (trimProp.length) {
                            [properties addObject:trimProp];
                        }
                    }
                }
            }
            
            JPJSClass *cls = [[JPJSClass alloc] initWithClass:clsName baseClass:baseClsName properties:properties];
            [classes addObject:cls];
        }
    }];
    return classes;
}

- (NSArray *)_methodsWithContent:(NSString *)content
{
    NSMutableArray *methods = [[NSMutableArray alloc] init];
    [_regexMethod enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *methodName;
            NSMutableArray *params = [[NSMutableArray alloc] init];
            NSString *methodStr = [content substringWithRange:result.range];
            NSArray *methodArr = [methodStr componentsSeparatedByString:@":"];
            if (methodArr.count > 1) {
                methodName = [methodArr[0] trim];
                NSString *functionStr = methodArr[1];
                NSArray *functionArr = [functionStr componentsSeparatedByString:@"("];
                if (functionArr.count > 1) {
                    NSArray *paramsArr = [[functionArr[1] stringByReplacingOccurrencesOfString:@")" withString:@""] componentsSeparatedByString:@","];
                    for (NSString *param in paramsArr) {
                        NSString *paramStr = [param trim];
                        if (paramStr.length) {
                            [params addObject:paramStr];
                        }
                    }
                }
                
            }
            JPJSMethod *method = [[JPJSMethod alloc] initWithMethodName:methodName params:params];
            [methods addObject:method];
            
        }
    }];
    return methods;
}

- (NSArray *)keywordCompletionItems
{
    @synchronized(self) {
        if (!_keywordCompletionItems) {
            _keywordCompletionItems = [[NSMutableArray alloc] init];
            NSArray *keywords = _keywords;
            for (NSString *keyword in keywords) {
                JPCompletionItem *item = [[JPCompletionItem alloc] initWithDictinary:@{
                                            kJPCompeletionName: keyword,
                                            kJPCompeletionDisplayText: keyword,
                                            kJPCompeletionText: keyword,
                                            kJPCompeletionDisplayType: @"Keyword",
                                            kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind],
                                            }];
                [_keywordCompletionItems addObject:item];
            }
        }
        return _keywordCompletionItems;
    }
}

- (NSArray *)_keywordsWithContent:(NSString *)content
{
    NSMutableArray *varArr = [[NSMutableArray alloc] init];
    
    [_regexKeyword enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *word = [content substringWithRange:result.range];
            if (![varArr containsObject:word]) {
                [varArr addObject:word];
            }
        }
    }];
    return varArr;
}

@end
