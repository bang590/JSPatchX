//
//  JPObjcClass.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPObjcClass : NSObject
@property (nonatomic, strong) NSArray *methods;  //include property method
@property (nonatomic, assign) BOOL isCategory;
@property (nonatomic, strong) NSString *clsName;
@property (nonatomic, strong) NSString *superClsName;
@property (nonatomic, strong) NSString *cateName;

-(instancetype)initWithParseResult:(void *)result;
@end
