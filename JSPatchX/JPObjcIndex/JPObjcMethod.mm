//
//  JPObjcMethod.m
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "JPObjcMethod.h"
#import "objcParser.h"
#import "JPObjcArg.h"
#import "JPCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"
#import "NSString+JSPatchX.h"


@implementation JPObjcMethod {
    JPCompletionItem *_completionItem;
}

-(instancetype)initWithParseResult:(void *)result{
    if (self  = [super init]) {
        MethodSymbol *msym = (MethodSymbol *)result;
        _methodName = [self createMethodName:result];
        _returnType = [[NSString stringWithUTF8String:msym->returnType.c_str()] trim];
        _isClassMethod = msym->isClassMethod != 0;
        
        _args = [[NSMutableArray alloc] initWithCapacity:msym->args.size()];
        for (int i = 0; i < msym->args.size(); ++i){
            ArgSymbol *argsym = msym->args[i];
            JPObjcArg *objcArg = [[JPObjcArg alloc] initWithParseResult:argsym];
            [_args addObject:objcArg];
        }
    }
    return self;
}

-(NSString *)createMethodName:(void *)result{
    MethodSymbol *msym = (MethodSymbol *)result;
    NSMutableString *mName = [[NSMutableString alloc] init];
    
    for (int i = 0; i < msym->args.size(); ++i){
        ArgSymbol * arg = msym->args[i];
        if (arg->selector.length()) {
            if (i != 0) {
                [mName appendString:@"_"];
            }
            NSString *selStr = [NSString stringWithCString:arg->selector.c_str() encoding:NSUTF8StringEncoding];
            [mName appendString:[selStr stringByReplacingOccurrencesOfString:@"_" withString:@"__"]];
        }
    }
    
    if (!msym->args.size()) {
        [mName appendFormat:@"%s", msym->methodName.c_str()];
    }
    
    return mName;
}

-(NSString *)displayString{
    NSMutableString * displayText = [[NSMutableString alloc] init];
    
    //prefix + or -
    if (_isClassMethod) {
        [displayText appendString:@"+"];
    }else{
        [displayText appendString:@"-"];
    }
    
    [displayText appendFormat:@"("];
    
    //return type
    [displayText appendString:_returnType];
    
    //method name
    [displayText appendFormat:@")%@(", _methodName];
    
    //args
    for (int i = 0; i < _args.count; ++i) {
        if (i != 0) {
            [displayText appendString:@", "];
        }
        JPObjcArg *arg = _args[i];
        if ([arg.argName isEqualToString:@"..."]) {
            [displayText appendString:@"..."];
        }else{
            [displayText appendFormat:@"%@ %@", arg.argType, arg.argName];
        }
    }
    
    //method end
    [displayText appendString:@")"];
    
    return displayText;
}

-(NSString *)completionString{
    NSMutableString * compString = [[NSMutableString alloc] init];
    
    //method name
    [compString appendFormat:@"%@(", _methodName];
    
    //args
    for (int i = 0; i < _args.count; ++i) {
        if (i != 0) {
            [compString appendString:@", "];
        }
        JPObjcArg *arg = _args[i];
        if ([arg.argName isEqualToString:@"..."]) {
            [compString appendString:@"<#...#\>"];
        }else{
            [compString appendFormat:@"<#%@ %@#\>", arg.argType, arg.argName];
        }
    }
    
    //method end
    [compString appendString:@")"];
    
    return compString;
}

- (JPCompletionItem *)completionItem
{
    if (!_completionItem) {
        _completionItem = [[JPCompletionItem alloc] initWithDictinary:@{
                                kJPCompeletionName: self.methodName,
                                kJPCompeletionDisplayText: self.displayString,
                                kJPCompeletionText: self.completionString,
                                kJPCompeletionDisplayType: self.className,
                                kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                }];
    }
    return _completionItem;
}

@end
