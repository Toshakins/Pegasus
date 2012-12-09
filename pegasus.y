%{
  #include <iostream>
  #include "utilites.h"
  
  extern char *curr_filename;
  
  
  /* Locations */
  #define YYLTYPE int              /* the type of locations */
  #define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
  for the location of tokens */
    
    extern int node_lineno;          /* set before constructing a tree node
    to whatever you want the line number
    for the tree node to be */
      
      
   #define YYLLOC_DEFAULT(Current, Rhs, N)         \
   Current = Rhs[1];                             \
   node_lineno = Current;
    
    
    #define SET_NODELOC(Current)  \
    node_lineno = Current;

    #define SETLOC(x, n) \
    x = n; \
    SET_NODELOC(n);
    
    void yyerror(char *s);        /*  defined below; called for each parse error */
    extern int yylex();           /*  the entry point to the lexer  */
%}

%union{
    char*  	ival;
    void*  	pval;
}
%token A B C D E H L
%token SP MOV XCHG ADI ACI ANA
%token RLC JNC INR CMA HLT NOP

%token <ival> DEC
%token <ival> BIN
%token <ival> HEX

%%

program
:directives 
{@$ = @1;}
|commands
{@$ = @1;};

directives: {}
|directives directive
{SETLOC(@$, @2)};

directive:
|ID EQU NUM
{consts[$1] = atoi($3); SETLOC(@$, @1);}
|ID DD NUM
{DDs[$1] = atoi($3); SETLOC(@$, @1);}
|ID DB NUM
{DBs[$1] = atoi($3); SETLOC(@$, @1);};

commands:
ID ':' command
{}
commands command
{};

command
:MOV REG ',' REG
{}
|XCHG
{}
|ADI NUM
{}
|ADI ID
{}
|ACI ID
{}
|ANA REG
{}
|RLC 
{}
|JNC ID
{}
|INR REG
{}
|CMA
{}
|HLT
{}
|NOP
{};


%%
void yyerror(char *s)
    {
      extern int curr_lineno;
      
      cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
      << s << " at or near " << yychar;
      cerr << endl;
      omerrs++;
      
      if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
    }