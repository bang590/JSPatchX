//
//  JPObjcImport.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPObjcImport : NSObject
@property (nonatomic, assign) BOOL isSys;
@property (nonatomic, strong) NSString *header;
-(instancetype)initWithParseResult:(void *)result;
@end
