//
//  JPJSClass.h
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPJSClass : NSObject
@property (nonatomic, strong, readonly) NSString *cls;
@property (nonatomic, strong, readonly) NSString *baseCls;
- (instancetype)initWithClass:(NSString *)cls baseClass:(NSString *)baseCls properties:(NSArray *)properties;
- (NSArray *)classCompletionItems;
- (NSArray *)propertyCompletionItems;
@end
