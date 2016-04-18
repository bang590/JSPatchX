//
//  JPObjcIndex.h
//  JSPatchX
//
//  Created by bang on 4/16/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IDEWorkspace;

@interface JPObjcIndex : NSObject
- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace;
- (NSArray *)methodCompletionItemsWithClasses:(NSArray *)classes;
- (NSArray *)protocolCompletionItems;
@end
