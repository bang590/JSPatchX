//
//  JPJSIndex.h
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IDEWorkspace;

@interface JPJSIndex : NSObject
- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace;
- (NSDictionary *)completionItemsInProject;
- (NSArray *)keywordCompletionItemsWithFilePath:(NSString *)filePath;
@end
