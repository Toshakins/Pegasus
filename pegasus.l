%{
#include <iostream>
#include "pegasus.tab.h"
using namespace std;

char* stralloc(const char* s);
int curr_lineno = 1;
%}

%%
;.*\n               {curr_lineno++;}//eat up comments
[ \f\r\t\v]+        ;
(?i:[a-ehlm])       {yylval.rval = *yytext; return REG; }
(?i:SP)             {return SP; }
[0-9]+              {yylval.val16 = atoi(yytext); return NUM;}//decimal number
[01]+b              {yylval.val16 = strtoul(yytext, NULL, 2); return NUM;}//binary
(?i:0[x][a-f0-9]+)  {yylval.val16 = strtoul(yytext + 2, NULL, 16); return NUM;}//hex
(?i:LDA)            {return LDA;}
(?i:STAX)           {return STAX;}
(?i:ADC)            {return ADC;}
(?i:ORA)            {return ORA;}
(?i:RAL)            {return RAL;}
(?i:JP)             {return JP;}
(?i:DCX)            {return DCX;}
(?i:CMC)            {return CMC;}
(?i:XCHG)           {return XCHG;}
(?i:LDAX)           {return LDAX;}
(?i:SHLD)           {return SHLD;}
(?i:SUB)            {return SUB;}
(?i:CMP)            {return CMP;}
(?i:RAR)            {return RAR;}
(?i:RLC)            {return RLC;}
(?i:JM)             {return JM;}
(?i:DCR)            {return DCR;}
(?i:STC)            {return STC;}
(?i:[a-z][a-z_]*)   {yylval.idval = stralloc(yytext); return ID;}
\n                  {curr_lineno++;}
":"                 {return *yytext;}
.                   {yylval.error_token = stralloc(yytext);return ERROR;}

%% 

char* stralloc(const char* s)
{
    char *d = (char*)malloc (strlen (s) + 1);   // Allocate memory
    if (d != NULL)
        strcpy (d,s);                    // Copy string if okay
    return d;                            // Return new memory
}