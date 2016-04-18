//
//  JPObjcProtocol.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPObjcProtocol : NSObject
@property (nonatomic, strong) NSString *protocolName;
- (instancetype)initWithParseResult:(void *)result;
- (NSArray *)methodCompletionItems;
@end
