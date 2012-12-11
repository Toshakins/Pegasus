%{

    #include <iostream>
    //#include "utilites.h"
    #include <cstdio>
    #include <vector>
    #include <fstream>        

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

%token ERROR LDA
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

}