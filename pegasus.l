%{
#include <iostream>
#include "pegasus.tab.h"
using namespace std;

%}

%%
;.*                 ;//eat up comments
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

(?i:[a-z][a-z_])    {yylval.idval = yytext; return ID;}
[ \t]               ;
\n                  ;
","                 {cout<<*yytext<<endl;return *yytext;}
.                   {cout <<"error"<<endl; return ERROR;}

%% 
