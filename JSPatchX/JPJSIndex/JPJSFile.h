//
//  JPJSFile.h
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPJSFile : NSObject
@property (nonatomic, strong, readonly) NSArray *requireClasses;
@property (nonatomic, strong, readonly) NSArray *classCompletionItems;
@property (nonatomic, strong, readonly) NSArray *methodCompletionItems;
@property (nonatomic, strong, readonly) NSArray *propertyCompletionItems;
@property (nonatomic, strong, readonly) NSArray *keywordCompletionItems;
- (instancetype)initWithContent:(NSString *)content;
@end
