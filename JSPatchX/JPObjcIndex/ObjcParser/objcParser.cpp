//
//  objcParser.cpp
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright (c) 2016年 louis. All rights reserved.
//

#include "objcParser.h"

    
int FileSymbol::parse(ObjcLex *lex){
    lex->next();
    while (!lex->isEOS()) {
        switch (lex->curToken().type) {
            case TT_import_usr:
            case TT_import_sys:
            {
                ImportSymbol  * imp = parseAndAdd<ImportSymbol>(lex);
                if (imp) {
                    imports.push_back(imp);
                }
            }
                break;
            case TT_interface:
            {
                InterfaceSymbol *itf = parseAndAdd<InterfaceSymbol>(lex);
                if (itf) {
                    interfaces.push_back(itf);
                }
                break;
            }
            case TT_protocol:
            {
                ProtocolSymbol *proto = parseAndAdd<ProtocolSymbol>(lex);
                if (proto) {
                    protocols.push_back(proto);
                }
                break;
            }
            default:
                lex->next();    //skip other token
                break;
        }
    }
    return PARSER_DONE;
}

int ImportSymbol::parse(ObjcLex *lex){
    if (lex->curToken().type == TT_import_sys) {
        isSys = 1;
    }else{
        isSys = 0;
    }
    
    lex->next();
    
    if (lex->curToken().type == TT_header) {
        path = lex->curToken().literal;
        lex->next();    //skip header
    }
    return PARSER_DONE;
}

int InterfaceSymbol::parse(ObjcLex *lex){
    checkAndNext(lex, TT_interface);
    
    //interface name
    if (checkToken(lex, TT_ident)) {
        clsName = lex->curToken().literal;
        lex->next();
        
        if (checkToken(lex, ';')) {
            return PARSER_ERROR;
        }
    }
    
    //super class name
    if (checkToken(lex, ':')) {
        lex->next();
        if (checkToken(lex, TT_ident)) {
            superClsName = lex->curToken().literal;
            lex->next();
        }
    }
    
    //check category
    if (checkToken(lex, '(')) {
        isCategory = true;
        lex->next();
        
        //record category name
        if (checkToken(lex, TT_ident)) {
            cateName = lex->curToken().literal;
            lex->next();
        }
        
        checkAndNext(lex, ')');
    }
    
    //skip tokens until method or @property decl or @end
    while (!checkToken(lex, TT_end) && !lex->isEOS()) {
        if (checkToken(lex, '+')) {
            //class method
            MethodSymbol *mts = parseAndAdd<MethodSymbol>(lex);
            if (!mts) {
                continue;
            }
            mts->isClassMethod = true;
            methods.push_back(mts);
        }else if (checkToken(lex, '-')){
            //instance method
            MethodSymbol *mts = parseAndAdd<MethodSymbol>(lex);
            if (!mts) {
                continue;
            }
            mts->isClassMethod = false;
            methods.push_back(mts);
        }else if (checkToken(lex, TT_property)){
            //property
            PropertySymbol * props = parseAndAdd<PropertySymbol>(lex);
            if (!props) {
                continue;
            }
            properties.push_back(props);
        }else{
            lex->next(); //skip
        }
    }
    
    lex->next();    //skip @end
    return PARSER_DONE;
}

int ProtocolSymbol::parse(ObjcLex *lex){
    checkAndNext(lex, TT_protocol);
    
    //interface name
    if (checkToken(lex, TT_ident)) {
        protoName = lex->curToken().literal;
        lex->next();
        
        if (checkToken(lex, ';')) {
            return PARSER_ERROR;
        }
    }

    
    //skip tokens until method or @property decl or @end
    while (!checkToken(lex, TT_end) && !lex->isEOS()) {
        if (checkToken(lex, '+')) {
            //class method
            MethodSymbol *mts = parseAndAdd<MethodSymbol>(lex);
            if (!mts) {
                continue;
            }
            mts->isClassMethod = true;
            methods.push_back(mts);
        }else if (checkToken(lex, '-')){
            //instance method
            MethodSymbol *mts = parseAndAdd<MethodSymbol>(lex);
            if (!mts) {
                continue;
            }
            mts->isClassMethod = false;
            methods.push_back(mts);
        }else if (checkToken(lex, TT_property)){
            //property
            PropertySymbol *props = parseAndAdd<PropertySymbol>(lex);
            if (!props) {
                continue;
            }
            properties.push_back(props);
        }else{
            lex->next(); //skip
        }
    }
    
    lex->next();    //skip @end
    return PARSER_DONE;
}

int PropertySymbol::parse(ObjcLex *lex){
    checkAndNext(lex, TT_property);
    
    //check attributes decl
    if (checkToken(lex, '(')) {
        //has attributes
        lex->next();
        
        while (checkToken(lex, TT_ident) && !lex->isEOS() && !checkToken(lex, '\n')) {
            attributes.push_back(lex->curToken().literal);
            lex->next();
            checkAndNext(lex, ',');
        }
        
        checkAndNext(lex, ')');
    }
    
    //record property type
    //type maybe has multi-token
    Token tk = lex->curToken();
    lex->next();
    for (; ; ) {
        if (tk.type == TT_ident && lex->curToken().type == ';') {
            // @property (automic, retain) int totalCount ;
            propertyName = tk.literal;
            break;
        }else if (tk.type == TT_ident && lex->curToken().type == TT_ident && lex->lookAhead().type == '('){
            // @property (automic, retain) int totalCount NS_AVAILABLE_MAC(10_10);
            propertyName = tk.literal;
            lex->next();
            
            //skip suffix
            while (lex->curToken().type != ';' && lex->curToken().type != '\n' && !lex->isEOS()) {
                lex->next();
            }
            break;
        }else if (lex->curToken().type == ';')
        {
            break;
        }else
        {
            if (lex->isEOS()) {
                return PARSER_ERROR;
            }
            if (tk.literal.length() == 0) {
                propertyType += (char)tk.type;
            }else{
                propertyType+=tk.literal;
                propertyType+=" ";
            }
            tk = lex->curToken();
            lex->next();
        }
    }
    
    checkAndNext(lex, ';');
    return PARSER_DONE;
}

int MethodSymbol::parse(ObjcLex *lex){
    if (checkToken(lex, '+')) {
        isClassMethod = true;
    }else if (checkToken(lex, '-')){
        isClassMethod = false;
    }else{
        return PARSER_ERROR;
    }
    
    lex->next(); //skip +,-
    
    //method return type is optional
    if (checkToken(lex, '(')) {
        lex->next();
        
        int parenLevel = 0;
        while (!checkToken(lex, ')') || parenLevel) {
            if (lex->curToken().literal.length() == 0) {
                returnType+=(char)lex->curToken().type;
                returnType+=" ";
            }else{
                returnType+=lex->curToken().literal;
                returnType+=" ";
                
                if (checkToken(lex, '(')) {
                    parenLevel++;
                }
                
                if (checkToken(lex, ')')) {
                    parenLevel--;
                }
            }
            
            if (lex->isEOS()) {
                break;
            }
            lex->next();
        }
        checkAndNext(lex, ')');
    }
    
    //record method name
    if (checkToken(lex, TT_ident)) {
        methodName = lex->curToken().literal;
        //lex->next();
    }else{
        //don't record nameless method
        return PARSER_ERROR;
    }
    
    if (lex->lookAhead().type == ':') {
        //has param list
        while ((checkToken(lex, TT_ident) && lex->lookAhead().type == ':') ||
               checkToken(lex, ',')) {
            ArgSymbol *arg = parseAndAdd<ArgSymbol>(lex);
            if (!arg) {
                continue;
            }
            args.push_back(arg);
            
            if (lex->isEOS()) {
                break;
            }
        }
        
        //skip suffix decl
        while (!checkToken(lex, ';') && !lex->isEOS()) {
            lex->next();
        }
    }else if (lex->lookAhead().type == ';'){
        //has no param list
        checkAndNext(lex, TT_ident);
    }else{
        while (!checkToken(lex, ';') && !lex->isEOS() && !checkToken(lex, '\n')) {
            lex->next();
        }
        return PARSER_DONE;
    }
    checkAndNext(lex, ';');
    return PARSER_DONE;
}

int ArgSymbol::parse(ObjcLex *lex){
    if (checkToken(lex, TT_ident)) {
        selector = lex->curToken().literal;
        lex->next();
        
        checkAndNext(lex, ':');
        if (checkToken(lex, '(')) {
            lex->next();
            
            int parenLevel = 0;
            while (lex->curToken().type != ')' || parenLevel) {
                if (lex->curToken().literal.length() == 0) {
                    argType += (char)lex->curToken().type;
                    argType += " ";
                }else{
                    argType += lex->curToken().literal;
                    argType += " ";
                }
                if (checkToken(lex, '(')) {
                    parenLevel++;
                }
                
                if (checkToken(lex, ')')) {
                    parenLevel--;
                }
                
                if (lex->isEOS()) {
                    break;
                }
                
                lex->next();
            }
            
            checkAndNext(lex, ')');
            
            if (checkToken(lex, TT_ident)) {
                argName = lex->curToken().literal;
                lex->next();
                return PARSER_DONE;
            }
        }
    }
    else if (checkAndNext(lex, ',')){
        if (checkAndNext(lex, TT_ellipsis)) {
            argName = "...";
            return PARSER_DONE;
        }
    }
    
    
    return PARSER_ERROR;
}
    
