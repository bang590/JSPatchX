//
//  JPWorkSpace.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEWorkspace.h"
#import "JPObjcIndex.h"
#import "JPJSIndex.h"

@interface IDEWorkspace (JSPatchX)

- (NSString *)currentProjectFolder;

- (NSArray *)defaultScanHeaderDirs;

- (NSArray *)SDKDirs;

- (NSString *)xcprojFile;

- (JPObjcIndex *)objcIndex;
- (JPJSIndex *)jsIndex;
@end
