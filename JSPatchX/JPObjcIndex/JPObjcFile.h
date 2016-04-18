//
//  JPObjcFile.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPObjcFile : NSObject
@property (nonatomic, strong) NSDate * parseDate;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSArray *classes;
@property (nonatomic, strong) NSArray * protocols;
@property (nonatomic, strong) NSArray * imports;
+ (JPObjcFile *)parseFile:(NSString *)path;
@end
