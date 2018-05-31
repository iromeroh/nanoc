.PHONY: default
default: nanoc ;
CC=gcc
LEX=flex
YACC=bison
CFLAGS=
ODIR=./
INCDIR=./
TESTDIR=./test
PROG_NAME=nanoc
BINDIR=.

lex.yy.c:
	$(LEX) c99.l
	
c99.tab.c:
	$(YACC) -d c99.y

nanoc: lex.yy.c c99.tab.c
	$(CC) -o $(BINDIR)/$(PROG_NAME) parser.c lex.yy.c c99.tab.c $(CFLAGS) $(LIBS)
	
test: nanoc
	cat $(TESTDIR)/test1.c | $(BINDIR)/$(PROG_NAME) 
	
clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~ lex.yy.c c99.tab.c c99.tab.h $(PROG_NAME)
