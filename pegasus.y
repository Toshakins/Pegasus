%{
  #include <iostream>
  #include "utilites.h"
  FILE *fin;
  
  extern char *curr_filename;
  
  uint8_t tmp; //temporary variable
  uint8_t *p;  //temporary pointer
  uint16t *addr;
  
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
    char*   idval;
    char    rval;
    uint16t ival;
}

%token MOV XCHG ADI ACI ANA EQU
%token RLC JNC INR CMA HLT NOP DB DD


%token <idval> ID
%token <rval>  REG
%token <ival>  NUM

%%

program
:commands
{@$ = @1;};

commands:
|ID ':' command commands 
{
if (!pointers[$1])
  pointers[$1] = ops.length(); SETLOC(@$, @1);
}
|ID ':' DD NUM commands
{
  DDs[$1] = $4; SETLOC(@$, @1);
}
|ID ':' DB NUM commands
{
  DDs[$1] = $4; SETLOC(@$, @1);
}
|ID EQU NUM commands
{
  consts[$1] = $3; SETLOC(@$, @1);
}
|command commands
{SETLOC(@$, @1);};

command
:MOV REG ',' REG
{
    tmp = mov($2, $4);
    if (tmp)
    {
        ops.push_back(tmp;)
    }
    SETLOC(@$, @1);
}
|XCHG
{ops.push_back(0xEB); SETLOC(@$, @1);}
|ADI NUM
{
    ops.push_back(0xC6);
    ops.push_back($2);
    SETLOC(@$, @1);
}
|ADI ID
{
    ops.push_back(0xC6);
    //super efficient
    p = consts[$2] ? consts[$2] : DBs[$2];
    if (p)
    {
        ops.push_back(*p);
    }
    SETLOC(@$, @1);
}
|ACI NUM
{
    ops.push_back(0xCE);
    ops.push_back($2);
    SETLOC(@$, @1);
}
|ACI ID
{
    ops.push_back(0xCE);
    p = consts[$2] ? consts[$2] : DBs[$2];
    if (p)
    {
        ops.push_back(*p);
    }
    SETLOC(@$, @1);
}
|ANA REG
{
    tmp = ana($2);
    if (tmp)
        ops.push_back(tmp);
    SETLOC(@$, @1);
}
|RLC 
{
    ops.push_back(0x07);
    SETLOC(@$, @1);
}
|JNC ID
{
    tmp = atoi($2);
    ops.push_back(0xD2);
    ops.push_back(tmp % 0xFF);
    ops.push_back(tmp / 0xFF);
}
|INR REG
{
    tmp = inr($2);
    if (tmp)
        ops.push_back(tmp);
    SETLOC(@$, @1);
}
|CMA
{
    ops.push_back(0x2F);
    SETLOC(@$, @1);
}
|HLT
{
    ops.push_back(0x76);
    SETLOC(@$, @1);
}
|NOP
{
   ops.push_back(0x00);
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

int main(int argc, char* argv[])
{
  // open a file handle to a particular file:
  fin = fopen(argv[1], "r");
  // make sure it's valid:
  if (!fin) {
    cout << "I can't open file!" << endl;
    return -1;
  }
  // set lex to read from it instead of defaulting to STDIN:
  yyin = fin;

  // parse through the input until there is no more:
  do {
    yyparse();
  } while (!feof(yyin));
  //output to binary here:
}