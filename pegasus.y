%{

    #include <iostream>
    #include "utilites.h"
    #include <cstdio>
    #include <vector>
    #include <fstream>    
    #include <cctype>    

    using namespace std;

    extern int yylex();           /*  the entry point to the lexer  */
    extern FILE * yyin;
    void yyerror(char *s);        /*  defined below; called for each parse error */

    vector<unsigned char> ops;
    
%}
%union{
    char rval;
    unsigned short val16;
    unsigned char val8;
    char* idval;
}

%token ERROR LDA STAX ADC ORA
%token RAL JP SP DCX CMC XCHG
%token LDAX
%token <rval> REG;
%token <val16> NUM;
%token <idval> ID
%%

program
:commands
{@$ = @1;}

commands:
|commands command;
command
:LDA NUM
{
    ops.push_back(0x3A);
    unsigned short t = $2;
    ops.push_back(t % 256);
    ops.push_back(t / 256);
}
|LDA ID
{
    //TODO
}
|STAX REG
{
    char ch = toupper($2);
    if (ch != 'B' && ch != 'H')
        YYERROR;
    if (ch == 'B')
        ops.push_back(0x02);
    if (ch == 'H')
        ops.push_back(0x12);
}
|ADC REG
{
    ops.push_back(adc($2));
}
|ORA REG
{
    ops.push_back(ora($2));
}
|RAL
{
    ops.push_back(0x17);
}
|JP NUM
{
    ops.push_back(0xF2);
    unsigned short t = $2;
    ops.push_back(t % 256);
    ops.push_back(t / 256);
}
|JP ID
{
    //TODO
}
|DCX REG
{
    unsigned char t = dcx($2);
    if (t)
        ops.push_back(t);
    else YYERROR;
}
|DCX SP
{
    ops.push_back(0x3B);
}
|CMC
{
    ops.push_back(0x3F);
}
|XCHG
{
    ops.push_back(0xEB);
}
|LDAX REG
{
    unsigned char t = ldax($2);
    if(t)
        ops.push_back(t);
    else YYERROR;
};
%%
int main(int argc, char **argv)
{
    if(!(yyin = fopen(argv[1], "r"))) {
        cout << "Can't open file\n";
    }
     do {
        yyparse();
    } while (!feof(yyin));
    
    fstream fout;
    fout.open(argv[2], fstream::binary | fstream::out);
    for (int i = 0; i < ops.size(); ++i)
    {
        fout << ops[i];
    }
}

void yyerror(char *s) {
    cerr << "OMG ERROR\n";
}