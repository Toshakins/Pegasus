%{
  #include <iostream>
  #include "utilites.h"
  
  extern char *curr_filename;
  
  uint8_t tmp; //temporary variable
  uint8_t *p;  //temporary pointer
  
  /* Locations */
  #define YYLTYPE int              /* the type of locations */
    
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
}

%token REG MOV XCHG ADI ACI ANA
%token RLC JNC INR CMA HLT NOP

%token <ival> NUM

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
|commands ID ':' command
{
if (!pointers[$2])
  pointers[$2] = commands.length; SETLOC(@$, @2);
}
commands command
{SETLOC(@$, @2);};

command
:MOV REG ',' REG
{
    tmp = mov($2, $4);
    if (tmp)
    {
        commands.push_back(tmp;)
    }
    SETLOC(@$, @1);
}
|XCHG
{commands.push_back(0xEB); SETLOC(@$, @1);}
|ADI NUM
{
    commands.push_back(0xC6);
    commands.push_back(atoi($2));
    SETLOC(@$, @1);
}
|ADI ID
{
    commands.push_back(0xC6);
    //super efficient
    p = consts[$2] ? consts[$2] : DBs[$2];
    if (p)
    {
        commands.push_back(*p);
    }
    SETLOC(@$, @1);
}
|ACI NUM
{
    commands.push_back(0xCE);
    commands.push_back(atoi($2));
    SETLOC(@$, @1);
}
|ACI ID
{
    commands.push_back(0xCE);
    p = consts[$2] ? consts[$2] : DBs[$2];
    if (p)
    {
        commands.push_back(*p);
    }
    SETLOC(@$, @1);
}
|ANA REG
{
    tmp = ana($2);
    if (tmp)
        commands.push_back(tmp);
    SETLOC(@$, @1);
}
|RLC 
{
    commands.push_back(0x07);
    SETLOC(@$, @1);
}
|JNC ID
{
    tmp = atoi($2);
    commands.push_back(0xD2);
    commands.push_back(tmp % 0xFF);
    commands.push_back(tmp / 0xFF);
}
|INR REG
{
    tmp = inr($2);
    if (tmp)
        commands.push_back(tmp);
    SETLOC(@$, @1);
}
|CMA
{
    commands.push_back(0x2F);
    SETLOC(@$, @1);
}
|HLT
{
    commands.push_back(0x76);
    SETLOC(@$, @1);
}
|NOP
{
   commands.push_back(0x00);
   SETLOC(@$, @1);
};


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