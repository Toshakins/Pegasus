%{
#include "pegasus.tab.h"
#include <cstdlib>
#include <stdint.h>

/* The compiler assumes these identifiers. */

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
    if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
        YY_FATAL_ERROR( "read() in flex scanner failed");

extern int curr_lineno;
extern int verbose_flag;

%}

/*
 * Define names for regular expressions here.
 */

DEC [:digit:]+
BIN [01]+b
HEX 0[xX][:xdigit:]+
IDEN  (?i:[a-z][a-z0-9_])
REGISTER (?i:[abcdehlm])

%%

;.*         ; //single-line comments
DEC         {yylval.ival = atoi(yytext); return NUM;}
BIN         {yylval.ival = strtoul(yytext, NULL, 2); return NUM;}
HEX         {yylval.ival = strtoul(yytext, NULL, 16); return NUM;}
REGISTER    {yylval.rval = *yytext; return REG;}
IDEN        {yylval.idval = yytext; return ID;}
(?i:MOV)    {return MOV;}
(?i:XCHG)   {return XCHG;}
(?i:ADI)    {return ADI;}
(?i:ACI)    {return ACI;}
(?i:ANA)    {return ANA;}
(?i:EQU)    {return EQU;}
(?i:RLC)    {return RLC;}
(?i:JNC)    {return JNC;}
(?i:INR)    {return INR;}
(?i:CMA)    {return CMA;}
(?i:HLT)    {return HLT;}
(?i:NOP)    {return NOP;}
(?i:DD)     {return DD;}
(?i:DB)     {return DB;}
[ \t]       ;
\n          {++curr_lineno;}
(","|":")   {return *yytext;}
.           {yylval.error_msg = yytext; return ERROR;}
