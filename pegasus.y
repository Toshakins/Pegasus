%{
    #include <iostream>
    #include "utilites.h"
    #include <cstdio>
    #include <vector>
    #include <fstream>    
    #include <cctype>
    #include <map>  

    using namespace std;

    extern int yylex();           /*  the entry point to the lexer  */
    extern FILE * yyin;
    void yyerror(char *s);        /*  defined below; called for each parse error */
    extern int yychar;
    extern int curr_lineno;
    extern char* yytext;

    vector<unsigned char> ops;
    map<string, unsigned short> definitions;
    map<string, vector<unsigned short> > mentions;

    void writeAddr(unsigned short position, unsigned short addr)
    {
        if (position == ops.size())
            ops.push_back(addr % 256);
        else 
            {
                ops[position] = addr % 256;
            }
        if (position + 1 == ops.size())
        {
            ops.push_back(addr / 256);
        }
        else 
        {
            ops[position + 1] = addr / 256;
        }
    }
    
%}

%union{
    char rval;
    unsigned short val16;
    unsigned char val8;
    char* idval;
    char* error_token;
}

%token ERROR LDA STAX ADC ORA
%token RAL JP SP DCX CMC XCHG
%token LDAX
%token <rval> REG;
%token <val16> NUM;
%token <idval> ID;
%%

program
:commands
{@$ = @1;}

commands:
|commands ID ':' command
{
    @$ = @2;
    if (!definitions[$2])
        definitions[$2] = ops.size();
    else
        YYERROR;
}
|commands command
{
    @$ = @2;
};

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
    ops.push_back(0x3A);
    if (mentions[$2].size())
    {
        writeAddr(ops.size(), definitions[$2]);
    }
    else{
        mentions[$2].push_back(ops.size());
        ops.push_back(0);
        ops.push_back(0);
    }
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
}
|ERROR
{
    YYERROR;
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

    typedef map<string, vector<unsigned short> >::iterator iter;
    for (iter it = mentions.begin(); it != mentions.end(); ++it)
    {
        if (mentions[it->first].size())
        {
            for (int i = 0; i < it->second.size(); ++i)
            {
                writeAddr(mentions[it->first][i], definitions[it->first]);
            }
        }
        else{
            //YYERROR;
        }
    }

    fstream fout;
    fout.open(argv[2], fstream::binary | fstream::out);
    for (int i = 0; i < ops.size(); ++i)
    {
        fout << ops[i];
    }
    for (std::map<string, unsigned short>::iterator i = definitions.begin();
     i != definitions.end(); ++i)
    {
        cout << i->first << ' ' << i->second << endl;
    }
}

void yyerror(char *s) {
    cerr << "Error near " << curr_lineno << " at " << yytext << endl;;
}