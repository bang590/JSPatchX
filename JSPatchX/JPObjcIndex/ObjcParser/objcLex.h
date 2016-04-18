//
//  objcLex.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright (c) 2016年 louis. All rights reserved.
//

#ifndef __objcLex__
#define __objcLex__

#include <stdio.h>
#include <string>

using namespace std;

static const int kFirstReserved = 257;
static const int kEOS = 0;

typedef enum {
    TT_interface = kFirstReserved,           //@interface
    TT_protocol,                             //@protocol
    TT_end,                                  //@end
    TT_import_sys,                           //#import
    TT_import_usr,
    TT_property,                             //@property
    TT_ident,
    TT_header,
    TT_ellipsis,                             //...
    TT_unknown,
    TT_eos,                    
}TokenType;

class Token{
public:
    string literal;
    int    type;
};

class ObjcLex{
public:
    ObjcLex(string &strSource);
    virtual ~ObjcLex();
    
    Token & curToken();
    Token & lookAhead();
    void next();
    int isEOS();
    
    int lineNum;
protected:
    int lex();
    int matchIdent();
    int matchInterface();
    int matchProtocol();
    int matchEnd();
    int matchImport();
    int matchProperty();
    
    void skipComment();
    void skipLongComment();
    void readString();
    
    int next_char();
    int test(int c);
    int testSet(string strset);
    
    
protected:
    string strSource;
    Token _curtk;
    Token _lookahead;
    int cur;
    int curChar;
    string buff;
    int bRecordIdent;
};


#endif /* defined(__objcLex__) */
