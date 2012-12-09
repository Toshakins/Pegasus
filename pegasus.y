/*
*  cool.y
*              Parser definition for the COOL language.
*
*/
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
%token A 258 B 259 C 260 D 261 E 264 H 265 L 266
%token SP 267 MOV 268 XCHG 269 ADI 270 ACI 271 ANA 272
%token RLC 273 JNC 274 INR 275 CMA 276 HLT 277 NOP 278


%token <ival> DEC
%token <ival> BIN
%token <ival> HEX

%type <ival>	program
%type <ival>	directives
%type <ival>	directive
%type <ival>	commands
%type <ival>	command
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
{}
|ID DD NUM
{}
|ID DB NUM
{};

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