//
//  JPObjcProtocol.m
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "JPObjcProtocol.h"
#import "objcParser.h"
#import "JPObjcMethod.h"
#import "JPObjcArg.h"

@implementation JPObjcProtocol {
    NSMutableArray *_methods;  //include property method
}

- (instancetype)initWithParseResult:(void *)result
{
    if (self = [super init]) {
        ProtocolSymbol *protosym = (ProtocolSymbol *)result;
        
        _methods = [[NSMutableArray alloc] initWithCapacity:protosym->methods.size()];
        _protocolName = [NSString stringWithUTF8String:protosym->protoName.c_str()];
        
        for (int idx = 0; idx < protosym->methods.size(); ++idx) {
            MethodSymbol *msym = protosym->methods[idx];
            JPObjcMethod *objcMethod = [[JPObjcMethod alloc] initWithParseResult:msym];
            objcMethod.className = _protocolName;
            [_methods addObject:objcMethod];
        }
        
        for (int idx = 0; idx < protosym->properties.size(); ++idx) {
            PropertySymbol *propsym = protosym->properties[idx];
            
            //getter
            JPObjcMethod *objcMethodGetter = [[JPObjcMethod alloc] init];
            objcMethodGetter.methodName = [NSString stringWithUTF8String:propsym->propertyName.c_str()];
            objcMethodGetter.returnType = [NSString stringWithUTF8String:propsym->propertyType.c_str()];
            objcMethodGetter.className = _protocolName;
            [_methods addObject:objcMethodGetter];
            if (![self isPropertyReadOnly:propsym]) {
                //setter
                JPObjcMethod *objcMethodSetter = [[JPObjcMethod alloc] init];
                objcMethodSetter.methodName = [NSString stringWithFormat:@"set%@",[NSString stringWithUTF8String:propsym->propertyName.c_str()]];
                objcMethodSetter.returnType = @"void";
                
                JPObjcArg *argSym = [[JPObjcArg alloc] init];
                argSym.argName = [[NSString stringWithUTF8String:propsym->propertyName.c_str()] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                argSym.selector = objcMethodSetter.methodName;
                argSym.argType = [objcMethodGetter.returnType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                objcMethodSetter.className = _protocolName;
                [_methods addObject:objcMethodSetter];
            }
        }

    }
    return self;
}


- (BOOL)isPropertyReadOnly:(PropertySymbol *)props
{
    for (int i = 0; i < props->attributes.size(); ++i){
        if (props->attributes[i] == "readonly") {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)methodCompletionItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (JPObjcMethod *method in _methods) {
        [items addObject:method.completionItem];
    }
    return items;
}
@end
