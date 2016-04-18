//
//  JPObjcClass.m
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "JPObjcClass.h"
#import "objcParser.h"
#import "JPObjcMethod.h"
#import "JPObjcArg.h"

@implementation JPObjcClass {
    NSMutableArray *_methods;
    BOOL _isCategory;
    NSString *_cateName;
    NSString *_clsName;
    NSString *_superClsName;
}

-(instancetype)initWithParseResult:(void *)result{
    if (self = [super init]) {
        InterfaceSymbol *itfsym = (InterfaceSymbol *)result;
        _methods = [[NSMutableArray alloc] initWithCapacity:itfsym->methods.size()];
        _isCategory = itfsym->isCategory != 0;
        _cateName = [NSString stringWithUTF8String:itfsym->cateName.c_str()];
        _clsName = [NSString stringWithUTF8String:itfsym->clsName.c_str()];
        _superClsName = [NSString stringWithUTF8String:itfsym->superClsName.c_str()];
        for (int idx = 0; idx < itfsym->methods.size(); ++idx) {
            MethodSymbol *msym = itfsym->methods[idx];
            JPObjcMethod *objcMethod = [[JPObjcMethod alloc] initWithParseResult:msym];
            objcMethod.className = _clsName;
            [_methods addObject:objcMethod];
        }
        
        for (int idx = 0; idx < itfsym->properties.size(); ++idx) {
            PropertySymbol *propsym = itfsym->properties[idx];
            
            //getter
            JPObjcMethod *objcMethodGetter = [[JPObjcMethod alloc] init];
            objcMethodGetter.methodName = [NSString stringWithUTF8String:propsym->propertyName.c_str()];
            objcMethodGetter.returnType = [NSString stringWithUTF8String:propsym->propertyType.c_str()];
            objcMethodGetter.className = _clsName;
            [_methods addObject:objcMethodGetter];
            
            if (![self isPropertyReadOnly:propsym]) {
                //setter
                JPObjcMethod *objcMethodSetter = [[JPObjcMethod alloc] init];
                objcMethodSetter.methodName = [NSString stringWithFormat:@"set%@",[NSString stringWithUTF8String:propsym->propertyName.c_str()]];
                if (objcMethodSetter.methodName.length > 3) {
                    NSString *c = [objcMethodSetter.methodName substringWithRange:NSMakeRange(3, 1)];
                    objcMethodSetter.methodName = [objcMethodSetter.methodName stringByReplacingCharactersInRange:NSMakeRange(3,1) withString:c.uppercaseString];
                }
                objcMethodSetter.returnType = @"void";
                
                
                JPObjcArg *objcArg = [[JPObjcArg alloc] init];
                objcArg.argName = [NSString stringWithUTF8String:propsym->propertyName.c_str()];
                objcArg.selector = objcMethodSetter.methodName;
                objcArg.argType = objcMethodGetter.returnType;
                
                objcMethodSetter.args = [NSMutableArray arrayWithObject:objcArg];
                objcMethodSetter.className = _clsName;
                [_methods addObject:objcMethodSetter];
            }
        }
        
        
    }
    return self;
}

-(BOOL)isPropertyReadOnly:(PropertySymbol *)props{
    for (int i = 0; i < props->attributes.size(); ++i){
        if (props->attributes[i] == "readonly") {
            return YES;
        }
    }
    return NO;
}
@end
