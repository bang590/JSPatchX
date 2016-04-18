//
//  objcLex.cpp
//  JSPatchX
//
//  Created by louis on 4/16/16.
//  Copyright (c) 2016年 louis. All rights reserved.
//

#include "objcLex.h"


ObjcLex::ObjcLex(string &source){
    this->strSource = source;
    _lookahead.type = TT_eos;
    _curtk.type = TT_unknown;
    cur = 1;
    lineNum = 1;
    curChar = source[0];
    bRecordIdent = 0;
}

ObjcLex::~ObjcLex(){

}

Token & ObjcLex::curToken(){
    return _curtk;
}

Token & ObjcLex::lookAhead(){
    if (_lookahead.type != TT_eos) {
        return _lookahead;
    }
    _lookahead.type = lex();
    _lookahead.literal = buff;
    return _lookahead;
}

void ObjcLex::next(){
    if (_lookahead.type != TT_eos) {
        _curtk = _lookahead;
        _lookahead.type = TT_eos;
        _lookahead.literal.clear();
        return;
    }
    
    _curtk.type = lex();
    _curtk.literal = buff;
}

int ObjcLex::lex(){
    buff.clear();
    int type = TT_eos;
    while (cur < strSource.size()) {
        switch (curChar) {
            case EOF:
                type = TT_eos;
                return type;
            case '@':
                next_char();
                if (test('p')) {
                    type = matchProtocol();
                    if (type != TT_protocol) {
                        type = matchProperty();
                    }
                }else if (test('i')){
                    type = matchInterface();
                }else if (test('e')){
                   type = matchEnd();
                }
                
                return type;
            case '#':
                next_char();
                type = matchImport();
                return type;
            case '"':
                //skip string
                next_char(); //skip "
                readString();
                type = TT_unknown;
                return type;
            case '/':
                next_char();  //skip /
                if (test('/')) {
                    skipComment();
                }else if (test('*')){
                    skipLongComment();
                }
                type = TT_unknown;
                return type;
            case '{':
            case '}':
            case '[':
            case ']':
            case '(':
            case ')':
            case '<':
            case '>':
            case ':':
            case ';':
            case '*':
            case '-':
            case '+':
            case ',':
            case '\n':
            case '^':
                type = curChar;
                next_char();
                if (bRecordIdent) {
                    return type;
                }
                return TT_unknown;
            case '.':
                next_char();
                if (testSet("..")) {
                    next_char();
                    next_char();
                    next_char();
                    return TT_ellipsis;
                }
                return '.';
            default:
                //skip other
                if ((isalpha(curChar) && !isspace(curChar)) || curChar=='_') {
                    //record ident
                    if (matchIdent() == TT_ident && buff.length() > 1) {
                        return TT_ident;
                    }
                    break;
                }else{
                    // skip
                    next_char();
                }
                break;
        }
    }
    return TT_unknown;
}

int ObjcLex::matchInterface(){
    if (testSet("interface")) {
        cur += 8;
        next_char();
        bRecordIdent = 1;
        return TT_interface;
    }
    return TT_unknown;
}

int ObjcLex::matchProtocol(){
    if (testSet("protocol")) {
        cur += 7;
        next_char();
        bRecordIdent = 1;
        return TT_protocol;
    }
    return TT_unknown;
}

int ObjcLex::matchImport(){
    if (testSet("import")) {
        cur+=5;
        next_char();
        
        //match header
        int sp;
        while (isspace(next_char())) {
        }
        
        if (test('"')) {
            sp = '"';
        }else if (test('<')){
            sp = '>';
        }else{
            return TT_unknown;
        }
        
        while (next_char() != sp) {
            buff.push_back(curChar);
        }
        
        next_char();
        
        _lookahead.type = TT_header;
        _lookahead.literal = buff;
        
        if (sp == '>') {
            return TT_import_sys;
        }else if (sp == '"') {
            return TT_import_usr;
        }
        
        return TT_unknown;
    }
    return TT_unknown;
}

int ObjcLex::matchEnd(){
    if (testSet("end")) {
        cur+= 2;
        next_char();
        bRecordIdent = 0;
        return TT_end;
    }
    return TT_unknown;
}

int ObjcLex::matchProperty(){
    if (testSet("property")) {
        cur+=7;
        next_char();
        bRecordIdent = 1;
        return TT_property;
    }
    return TT_unknown;
}

int ObjcLex::matchIdent(){
    buff.push_back(curChar);
    next_char();
    while ((isalpha(curChar) || isdigit(curChar) || curChar == '_') && !isEOS()) {
        buff.push_back(curChar);
        next_char();
    }
    if (!bRecordIdent) {
        return TT_unknown;
    }
    return TT_ident;
}

void ObjcLex::skipComment(){
    next_char();
    while (next_char() != '\n' && !isEOS()) {
    }
    next_char(); //skip '\n'
}

void ObjcLex::skipLongComment(){
    next_char();
    for (; ; ) {
        if (curChar == '*') {
            next_char();
            if (curChar == '/') {
                next_char();
                return;
            }
        }else{
            next_char();
        }
        
        if (isEOS()) {
            break;
        }
    }
}

void ObjcLex::readString(){

    while (curChar != '"' && !isEOS()) {
        next_char();
        if (curChar == '\\') {
            //skip '\"'
            next_char();
        }else{
            //buff.push_back(curChar);
        }
    }
    next_char();
}

int ObjcLex::isEOS(){
    if (cur >= (int)strSource.size()) {
        return true;
    }
    return false;
}

int ObjcLex::next_char(){
    if (isEOS()) {
        return EOF;
    }
    
    if (curChar == '\n') {
        lineNum++;
    }
    curChar = strSource[cur++];
    
    return curChar;
}

int ObjcLex::test(int c){
    if (isEOS() && c == EOF ) {
        return true;
    }else{
        return c == curChar;
    }
}

int ObjcLex::testSet(string strset){
    int idx = 0;
    int c = curChar;
    do {
        if (c == strset[idx]) {
            c = strSource[cur + (idx++)];
            continue;
        }else{
            break;
        }
        
    } while (idx + cur < strSource.size() && idx < strset.size());
    
    return idx >= strset.length();
}

