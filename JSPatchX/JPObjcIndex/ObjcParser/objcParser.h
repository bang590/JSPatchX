//
//  objcParser.h
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright (c) 2016年 louis. All rights reserved.
//

#ifndef __objcParser__
#define __objcParser__

#include <stdio.h>
#include <string>
#include <vector>
#include "objcLex.h"


using namespace std;

class FileSymbol;
//toplevel symbol
class ImportSymbol;
class InterfaceSymbol;
class ProtocolSymbol;
//sub level symbol
class MethodSymbol;
class PropertySymbol;
class ArgSymbol;

#define PARSER_DONE 0
#define PARSER_ERROR 1

typedef enum {
    ST_File,
    ST_Import,
    ST_Interface,
    ST_Protocol,
    ST_Method,
    ST_Property,
    ST_Arg,
    ST_Unknown,
} SymbolType;

class Node{
public:
    vector<Node*> childs;
    int type;
    int lineNum;
public:
    Node(){
        type = ST_Unknown;
    }
    
    virtual ~Node(){
        for (int i = 0; i < childs.size(); ++i) {
            delete childs[i];
        }
        childs.clear();
    }
    
    template<class T>
    T * parseAndAdd(ObjcLex *lex){
        T *n = new T();
        n->lineNum = lex->lineNum;
        int ret = n->parse(lex);
        if (ret == PARSER_DONE){
            childs.push_back(n);
            return n;
        }
        delete n;
        n = NULL;
        return n;
    }
    
    virtual int parse(ObjcLex *lex) = 0;
protected:
    int checkToken(ObjcLex *lex, int ttype){
        return lex->curToken().type == ttype;
    }
    
    int checkAndNext(ObjcLex *lex, int ttype){
        if (checkToken(lex, ttype)) {
            lex->next();
            return 1;
        }
        return 0;
    }
};

class FileSymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    vector<ImportSymbol *>  imports;
    vector<InterfaceSymbol *>   interfaces;
    vector<ProtocolSymbol *>    protocols;
};

class ImportSymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    string path;
    int    isSys;
};

class InterfaceSymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    string          clsName;
    string          cateName;
    string          superClsName;
    int             isCategory;
    vector<string>  protocols;
    vector<MethodSymbol *> methods;
    vector<PropertySymbol *> properties;
};

class ProtocolSymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    string                  protoName;
    vector<string>          protocols;
    vector<MethodSymbol *>  methods;
    vector<PropertySymbol *> properties;
};

class MethodSymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    string              methodName;
    string              returnType;
    vector<ArgSymbol *> args;
    int                 isClassMethod;
};

class PropertySymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    string              propertyName;
    vector<string>      attributes;     //readonly, copy, retain ...
    string              propertyType;
};

class ArgSymbol: public Node{
public:
    virtual int parse(ObjcLex *lex);
public:
    string          selector;   //optional
    string          argType;    //optional
    string          argName;    //required
};


#endif /* defined(__objcParser__) */
