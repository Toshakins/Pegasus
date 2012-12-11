pegasus.tab.c pegasus.tab.h: pegasus.y
	bison -d pegasus.y

lex.yy.c: pegasus.l pegasus.tab.h
	flex pegasus.l

pegasus: lex.yy.c pegasus.tab.c pegasus.tab.h
	g++ pegasus.tab.c lex.yy.c -lfl -o pegasus