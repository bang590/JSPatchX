//
//  JPJSMethod.h
//  JSPatchX
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPCompletionItem.h"

@interface JPJSMethod : NSObject
- (instancetype)initWithMethodName:(NSString *)name params:(NSArray *)params;
- (JPCompletionItem *)completionItem;
@end
