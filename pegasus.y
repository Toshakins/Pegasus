%{
  #include <iostream>
  #include "utilites.h"
  #include <vector>
  #include <map>
  #include <cstdio>
  #include <fstream>

  using namespace std;

  extern FILE * yyin;

  int omerrs = 0;//num of errors

  typedef unsigned short uint16_t;
  typedef unsigned char uint8_t;

  vector<uint8_t> ops;
  //to search for unknown labels further in program
  map<string, vector<uint16_t> > lookup;
  map<string, uint8_t> consts;
  map<string, uint8_t> MEM;
  //points to address in bin file
  map<string, uint16_t> pointers;

  FILE *fin;

  extern uint8_t inr(char r);
  extern uint8_t ana(char r);
  extern uint8_t mov(char x, char y);

  const uint16_t memlen = 1024;
  
  uint8_t tmp; //temporary variables

  
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
    unsigned short ival;
    char*   error_msg;
}

%token MOV XCHG ADI ACI ANA EQU
%token RLC JNC INR CMA HLT NOP DB DD


%token <idval> ID
%token <rval>  REG
%token <ival>  NUM
%token <error_msg> ERROR

%%

program
:commands
{@$ = @1;};

commands:
|ID ':' command commands 
{
if (!pointers[$1])
  pointers[$1] = ops.size() + memlen - 2; SETLOC(@$, @1);//WARNING
}
|ID ':' DD NUM commands
{
  MEM[$1] = $4;
  pointers[$1] = MEM.size() - 1;
  SETLOC(@$, @1);
}
|ID ':' DB NUM commands
{
  MEM[$1] = $4;
  pointers[$1] = MEM.size() - 1;
  SETLOC(@$, @1);
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
        ops.push_back(tmp);
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
    tmp = consts[$2] ? consts[$2] : MEM[$2];
    if (tmp)
    {
        ops.push_back(tmp);
    }
    SETLOC(@$, @1);
}
|ACI NUM
{
    ops.push_back(0xCE);
    ops.push_back($2 % 256);
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
|JNC NUM
{
    uint16_t t = $2 % 65536;
    ops.push_back(0xD2);
    ops.push_back(t % 0xFF);
    ops.push_back(t / 0xFF);
}
|JNC ID
{
    uint16_t t = consts[$2] ? consts[$2] : MEM[$2];
    ops.push_back(0xD2);
    if (t % 255)
    {
        ops.push_back(t % 255);
        ops.push_back(t / 255);
    }
    else{
        lookup[$2].push_back(ops.size());
        ops.push_back(0x00);
        ops.push_back(0x00);
    }
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
    
    cerr << "\"" << "this file"<< "\", line " << curr_lineno << ": " \
    << s << " at or near " << yychar;
    cerr << endl;
    omerrs++;
    
    if(omerrs>50) {cout << "More than 50 errors\n"; exit(1);}
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
  //check lookup table:
  map<string, std::vector<uint16_t> >::iterator lookupit;
  string lkpKey;
  uint16_t addr;
  for (map<string, vector<uint16_t> >::iterator it = lookup.begin(); it != lookup.end(); it++)
  {
    lkpKey = (*it).first;
    addr = MEM[lkpKey] ? MEM[lkpKey] : consts[lkpKey];
    if (addr)
    {
        //processing with addresses in opcodes
        for (std::vector<uint16_t>::iterator j = (*it).second.begin(); j != (*it).second.end(); ++j)
        {
            ops[*j] = addr % 255;
            ops[*j + 1] = addr / 255;
        }
    }
    else{
        cerr << "Can't found address at" << lkpKey << endl;
        return -1;
    }
  }

  //output to binary here:
  fstream fout;
  fout.open(argv[2], fstream::binary | fstream::out);
  int i = 1;
  fout << 0x00; //magic byte, nobody can reference it
  map<string, uint8_t>::iterator it8 = MEM.begin();
  for (;it8 != MEM.end(); it8++)
  {
      ++i;
      fout << (uint8_t)(*it8).second;
  }
  it8 = consts.begin();
  for (;it8 != consts.end(); it8++)
  {
      ++i;
      fout << (uint8_t)(*it8).second;
  }
  if (i > memlen)
  {
    cerr << "Out of mysterious 1024 bound\n";
    return -1;
  }
  for (int j = i; j < memlen; ++j)
  //fill up with zeros
      fout << 0x00;
  //commands write acquired now
  for (i = 0; i < ops.size(); ++i)
  {
      fout << ops[i];
  }
  return 0;
}