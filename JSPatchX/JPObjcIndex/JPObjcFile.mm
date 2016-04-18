//
//  JPObjcFile.m
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "JPObjcFile.h"
#import "objcLex.h"
#import "objcParser.h"
#import "JPObjcProtocol.h"
#import "JPObjcImport.h"
#import "JPObjcClass.h"

@implementation JPObjcFile {
    NSMutableArray *_imports;
    NSMutableArray *_classes;
    NSMutableArray *_protocols;
}

+ (JPObjcFile *)parseFile:(NSString *)path
{
    @try {
        NSData *sourceData = [NSData dataWithContentsOfFile:path];
        if (!sourceData.length) {
            return NULL;
        }
        string utfSource((const char *)sourceData.bytes, sourceData.length);
        ObjcLex lex(utfSource);
        FileSymbol fssym;
        
        fssym.parse(&lex);
        
        JPObjcFile *objcFile = [[JPObjcFile alloc] initWithParseResult:&fssym];
        objcFile.parseDate = [NSDate date];
        objcFile.filePath = path;
        
        return objcFile;
    }
    @catch (NSException *exception) {
        NSLog(@"ObjectiveC Header Parse Error:%@", path);
        return nil;
    }
    @finally {
    }
}

-(instancetype)initWithParseResult:(void *)result
{
    if (self = [super init]) {
        FileSymbol * fs = (FileSymbol *)result;
        
        _imports = [[NSMutableArray alloc] initWithCapacity:fs->imports.size()];
        for(int idx = 0; idx < fs->imports.size(); ++idx){
            ImportSymbol *imps = fs->imports[idx];
            JPObjcImport *objcImport = [[JPObjcImport alloc] initWithParseResult:imps];
            [_imports addObject:objcImport];
        }
        
        _classes = [[NSMutableArray alloc] initWithCapacity:fs->interfaces.size()];
        for(int idx = 0; idx < fs->interfaces.size(); ++idx){
            InterfaceSymbol *itfs = fs->interfaces[idx];
            JPObjcClass *objcCls = [[JPObjcClass alloc] initWithParseResult:itfs];
            [_classes addObject:objcCls];
        }
        
        _protocols = [[NSMutableArray alloc] initWithCapacity:fs->protocols.size()];
        for(int idx = 0; idx < fs->protocols.size(); ++idx){
            ProtocolSymbol *protos = fs->protocols[idx];
            JPObjcProtocol *objcProtocol = [[JPObjcProtocol alloc] initWithParseResult:protos];
            [_protocols addObject:objcProtocol];
        }
        
    }
    return self;
}

@end
