%{
#include <string.h>
#include <stdlib.h>
#include "parser.h"
void log(const char *format, ...);

%}

%union
{
    char charValue;
    unsigned char ucharValue;
    short int shortValue;
    unsigned short int ushortValue;
    int intValue;
    unsigned int uintValue;
    long int longValue;
    unsigned long int ulongValue;
    float floatValue;
    double doubleValue;
    long double ldoubleValue;
    char *stringValue;
    char *idValue;
    ExprType exprValue;
}

%token <idValue> IDENTIFIER
%token <charValue> CHAR_CONSTANT
%token <longValue> INT_CONSTANT
%token <doubleValue> FLOAT_CONSTANT
%token <stringValue> STRING_LITERAL
%token SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token BOOL COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%type <exprValue> primary_expression
%type <exprValue> expression
%type <exprValue> postfix_expression
%type <exprValue> argument_expression_list
%type <exprValue> type_name
%type <exprValue> initializer_list
%type <exprValue> assignment_expression
%type <exprValue> unary_expression
%type <exprValue> cast_expression
%type <exprValue> unary_operator
%type <exprValue> multiplicative_expression
%type <exprValue> additive_expression
%type <exprValue> shift_expression
%type <exprValue> relational_expression
%type <exprValue> equality_expression
%type <exprValue> and_expression
%type <exprValue> exclusive_or_expression
%type <exprValue> inclusive_or_expression
%type <exprValue> logical_and_expression
%type <exprValue> logical_or_expression
%type <exprValue> conditional_expression
%type <exprValue> assignment_operator

%start translation_unit
%%

primary_expression
    : IDENTIFIER
    {
        LinkedList * value = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = ID_NAME;
        $$.items = value;
        log("\nidentifier '%s'",$1);
    }
    | CHAR_CONSTANT
    {
        LinkedList * value = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = CHAR_LITERAL;
        $$.items = value;
        log("\nchar constant '%c'",$1);
    }
    | INT_CONSTANT
    {
        LinkedList * value = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = INT_LITERAL;
        $$.items = value;
        log("\nint constant '%d'",$1);
    }
    | FLOAT_CONSTANT
    {
        LinkedList * value = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = FLOAT_LITERAL;
        $$.items = value;
        log("\nfloat constant '%f'",$1);
    }
    | STRING_LITERAL
    {
        LinkedList * value = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = STR_LITERAL;
        $$.items = value;
        log("\nstring literal '%s'",$1);
    }
    | '(' expression ')'
    {
            $$ = $2;
        log("\n( primary expression )");

    }
    | error
    {
       log("\nSyntax error on primary expression");
    }
    ;

postfix_expression
    : primary_expression
    {
            $$ = $1;
        log("\npostfix expression - primary expr");
    }
    | postfix_expression '[' expression ']'
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = ARRAY_INDEX_SEM;
        $$.items = subexpressions;
        log("\npostfix expression - array indexation");
    }
    | postfix_expression '(' ')'
    {
        LinkedList * call_noparam_expression = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = FUNC_CALL_NOPARAMS_SEM;
        $$.items = call_noparam_expression;
        log("\npostfix expression - func call ()");
    }
    | postfix_expression '(' argument_expression_list ')'
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = FUNC_CALL_SEM;
        $$.items = subexpressions;
        log("\npostfix expression - func call ( params )");
    }
    | postfix_expression '.' IDENTIFIER
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = STRUCT_SELECT_SEM;
        $$.items = subexpressions;
        log("\npostfix expression - struct select");
    }
    | postfix_expression PTR_OP IDENTIFIER
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = STRUCT_PTR_SELECT_SEM;
        $$.items = subexpressions;
        log("\npostfix expression - struct ptr select");
    }
    | postfix_expression INC_OP
    {
        LinkedList * postfix_inc_expression = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = POSTFIX_INC_SEM;
        $$.items = postfix_inc_expression;
        log("\npostfix expression - post fix inc (++)");
    }
    | postfix_expression DEC_OP
    {
        LinkedList * postfix_dec_expression = list_create((void*) &($1), sizeof(union YYSTYPE));
        $$.op = POSTFIX_DEC_SEM;
        $$.items = postfix_dec_expression;
        log("\npostfix expression - post fix dec (--)");
    }
    | '(' type_name ')' '{' initializer_list '}'
    {
        LinkedList * subexpressions = list_create((void*) &($2), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($5), sizeof(union YYSTYPE) );
        $$.op = C99_WEIRD_SEM1;
        $$.items = subexpressions;

        log("\npostfix expression 9");
    }
    | '(' type_name ')' '{' initializer_list ',' '}'
    {
        LinkedList * subexpressions = list_create((void*) &($2), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($5), sizeof(union YYSTYPE) );
        $$.op = C99_WEIRD_SEM2;
        $$.items = subexpressions;
        log("\npostfix expression 10");
    }
    ;

argument_expression_list
    : assignment_expression
    {
        $$ = $1;
        log("\nargument expression list 1");
    }
    | argument_expression_list ',' assignment_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = ARGUMENT_COMMA_SEM;
        $$.items = subexpressions;
        log("\nargument expression list 2");
    }
    ;

unary_expression
    : postfix_expression
    {
        $$ = $1;
        log("\nunary expression - postfix expr");
    }
    | INC_OP unary_expression
    {
        LinkedList * prefix_inc_expression = list_create((void*) &($2), sizeof(union YYSTYPE));
        $$.op = PREFIX_INC_SEM;
        $$.items = prefix_inc_expression;
        log("\nprefix inc (++) expression");
    }
    | DEC_OP unary_expression
    {
        LinkedList * prefix_inc_expression = list_create((void*) &($2), sizeof(union YYSTYPE));
        $$.op = PREFIX_DEC_SEM;
        $$.items = prefix_inc_expression;
        log("\nprefix dec (--) expression 3");
    }
    | unary_operator cast_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($2), sizeof(union YYSTYPE) );
        $$.op = CONCRETE_UNARY_OP_SEM;
        $$.items = subexpressions;
        log("\nunary expression - concrete unary op at left");
    }
    | SIZEOF unary_expression
    {
        LinkedList * prefix_inc_expression = list_create((void*) &($2), sizeof(union YYSTYPE));
        $$.op = SIZEOF_SEM;
        $$.items = prefix_inc_expression;
        log("\nunary expression - Sizeof");
    }
    | SIZEOF '(' type_name ')'
    {
        LinkedList * prefix_inc_expression = list_create((void*) &($3), sizeof(union YYSTYPE));
        $$.op = SIZEOF_TYPE_SEM;
        $$.items = prefix_inc_expression;
        log("\nunary expression - Sizeof (type)");
    }
    ;

unary_operator
    : '&'
    {
        $$.op = AMPERSAND;
        $$.items = NULL;
        log("\nunary operator &");
    }
    | '*'
    {
        $$.op = ASTERISK;
        $$.items = NULL;
        log("\nunary operator *");
    }
    | '+'
    {
        $$.op = PLUS;
        $$.items = NULL;
        log("\nunary operator +");
    }
    | '-'
    {
        $$.op = MINUS;
        $$.items = NULL;
        log("\nunary operator -");
    }
    | '~'
    {
        $$.op = TILDE;
        $$.items = NULL;
        log("\nunary operator ~");
    }
    | '!'
    {
        $$.op = EXCLAMATION;
        $$.items = NULL;
        log("\nunary operator !");
    }
    ;

cast_expression
    : unary_expression
    {
        $$ = $1;
        log("\ncast expression unary");
    }
    | '(' type_name ')' cast_expression
    {
        LinkedList * subexpressions = list_create((void*) &($2), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($4), sizeof(union YYSTYPE) );
        $$.op = CAST_EXPR_SEM;
        $$.items = subexpressions;
        log("\ncast expression ()");
    }
    ;

multiplicative_expression
    : cast_expression
    {
        $$ = $1;
        log("\nmultiplicative expression cast");
    }
    | multiplicative_expression '*' cast_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = MULTIPLICATE_SEM;
        $$.items = subexpressions;
        log("\nmultiplicative expression *");
    }
    | multiplicative_expression '/' cast_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = DIVIDE_SEM;
        $$.items = subexpressions;
        log("\ndivide expression /");
    }
    | multiplicative_expression '%' cast_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = MODULO_SEM;
        $$.items = subexpressions;
        log("\nmodulo expression %");
    }
    ;

additive_expression
    : multiplicative_expression
    {
        $$ = $1;
        log("\nadditive expression multiplicative");
    }
    | additive_expression '+' multiplicative_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = ADDITION_SEM;
        $$.items = subexpressions;
        log("\nadditive expression +");
    }
    | additive_expression '-' multiplicative_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = REST_SEM;
        $$.items = subexpressions;
        log("\nadditive expression +");
        log("\nadditive expression -");
    }
    ;

shift_expression
    : additive_expression
    {
       $$ = $1;
        log("\nshift expression additive");
    }
    | shift_expression LEFT_OP additive_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = LSHIFT_SEM;
        $$.items = subexpressions;
        log("\nshift expression <<");
    }
    | shift_expression RIGHT_OP additive_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = RSHIFT_SEM;
        $$.items = subexpressions;
        log("\nshift expression >>");
    }
    ;

relational_expression
    : shift_expression
    {
        $$ = $1;
        log("\nrelational expression shift");
    }
    | relational_expression '<' shift_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = LESS_THAN_SEM;
        $$.items = subexpressions;
        log("\nrelational expression <");
    }
    | relational_expression '>' shift_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = GREATER_THAN_SEM;
        $$.items = subexpressions;
        log("\nrelational expression >");
    }
    | relational_expression LE_OP shift_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = LESS_OR_EQUAL_SEM;
        $$.items = subexpressions;
        log("\nrelational expression <=");
    }
    | relational_expression GE_OP shift_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = GREATER_OR_EQUAL_SEM;
        $$.items = subexpressions;
        log("\nrelational expression >=");
    }
    ;

equality_expression
    : relational_expression
    {
        $$ = $1;
        log("\nequality expression - relational");
    }
    | equality_expression EQ_OP relational_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = EQUALS_SEM;
        $$.items = subexpressions;
        log("\nequality expression ==");
    }
    | equality_expression NE_OP relational_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = NOT_EQUALS_SEM;
        $$.items = subexpressions;

    log("\nequality expression !=");
    }
    ;

and_expression
    : equality_expression
    {
        $$ = $1;
        log("\nand expression - equality");
    }
    | and_expression '&' equality_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = AND_SEM;
        $$.items = subexpressions;

        log("\nand expression &");
    }
    ;

exclusive_or_expression
    : and_expression
    {
        $$ = $1;
        log("\nexclusive or expression 1");
    }
    | exclusive_or_expression '^' and_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = XOR_SEM;
        $$.items = subexpressions;
        log("\nexclusive or expression 2");
    }
    ;

inclusive_or_expression
    : exclusive_or_expression
    {
        $$ = $1;
        log("\ninclusive or expression - exclusive or expr");
    }
    | inclusive_or_expression '|' exclusive_or_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = OR_SEM;
        $$.items = subexpressions;
        log("\ninclusive or expression |");
    }
    ;

logical_and_expression
    : inclusive_or_expression
    {
        $$ = $1;
        log("\nlogical and expression - inclusive or expr");
    }
    | logical_and_expression AND_OP inclusive_or_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = LOGIC_AND_SEM;
        $$.items = subexpressions;
        log("\nlogical and expression &&");
    }
    ;

logical_or_expression
    : logical_and_expression
    {
        $$ = $1;
        log("\nlogical or expression 1");
    }
    | logical_or_expression OR_OP logical_and_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = LOGIC_OR_SEM;
        $$.items = subexpressions;

        log("\nlogical or expression 2");
    }
    ;

conditional_expression
    : logical_or_expression
    {
        $$ = $1;
        log("\nconditional expression - logical or expr");
    }
    | logical_or_expression '?' expression ':' conditional_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        append(subexpressions, (void*) &($5), sizeof(union YYSTYPE) );
        $$.op = CONDITIONAL_EXPR_SEM;
        $$.items = subexpressions;

        log("\nconditional expression :");
    }
    ;

assignment_expression
    : conditional_expression
    {
        $$ = $1;
        log("\nassignment expression 1");
    }
    | unary_expression assignment_operator assignment_expression
    {
        LinkedList * subexpressions = list_create((void*) &($1), sizeof(union YYSTYPE));
        append(subexpressions, (void*) &($3), sizeof(union YYSTYPE) );
        $$.op = $2.op;
        $$.items = subexpressions;
        log("\nassignment expression 2");
    }
    ;

assignment_operator
    : '='
    {
        $$.op = ASSIGN_SEM;
        $$.items = NULL;
    
        log("\nassignment operator =");
    }
    | MUL_ASSIGN
    {
        $$.op = MUL_ASSIGN_SEM;
        $$.items = NULL;
    
        log("\nassignment operator *=");
    }
    | DIV_ASSIGN
    {
        $$.op = DIV_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator /=");
    }
    | MOD_ASSIGN
    {
        $$.op = MOD_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator %=");
    }
    | ADD_ASSIGN
    {
        $$.op = ADD_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator +=");
    }
    | SUB_ASSIGN
    {
        $$.op = SUB_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator -=");
    }
    | LEFT_ASSIGN
    {
        $$.op = LEFT_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator <<=");
    }
    | RIGHT_ASSIGN
    {
        $$.op = RIGHT_ASSIGN_SEM;
        $$.items = NULL;
    
        log("\nassignment operator >>=");
    }
    | AND_ASSIGN
    {
        $$.op = AND_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator &=");
    }
    | XOR_ASSIGN
    {
        $$.op = XOR_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator ^=");
    }
    | OR_ASSIGN
    {
        $$.op = OR_ASSIGN_SEM;
        $$.items = NULL;

        log("\nassignment operator |=");
    }
    ;

expression
    : assignment_expression
    {
        log("\nExpression 1");
    }
    | expression ',' assignment_expression
    {
        log("\nExpression 2");
    }
    ;

constant_expression
    : conditional_expression
    {
        log("\nconstant expression");
    }
    ;

declaration
    : declaration_specifiers ';'
    {
        log("\nDeclaration 1");
    }
    | declaration_specifiers init_declarator_list ';'
    {
        log("\nDeclaration 2");
    }
    ;

declaration_specifiers
    : storage_class_specifier
    {
        log("\ndeclaration specifier 1");
    }
    | storage_class_specifier declaration_specifiers
    {
        log("\ndeclaration specifier 2");
    }
    | type_specifier
    {
        log("\ndeclaration specifier 3");
    }
    | type_specifier declaration_specifiers
    {
        log("\ndeclaration specifier 4");
    }
    | type_qualifier
    {
        log("\ndeclaration specifier 5");
    }
    | type_qualifier declaration_specifiers
    {
        log("\ndeclaration specifier 6");
    }
    | function_specifier
    {
        log("\ndeclaration specifier 7");
    }
    | function_specifier declaration_specifiers
    {
        log("\ndeclaration specifier 8");
    }
    ;

init_declarator_list
    : init_declarator
    {
        log("\ninit declarator list 1");
    }
    | init_declarator_list ',' init_declarator
    {
        log("\ninit declarator list 2");
    }
    ;

init_declarator
    : declarator
    {
        log("\ninit declarator 1");
    }
    | declarator '=' initializer
    {
        log("\ninit declarator 2");
    }
    ;

storage_class_specifier
    : TYPEDEF
    {
        log("\nstorage class specifier typedef");
    }
    | EXTERN
    {
        log("\nstorage class specifier extern");
    }
    | STATIC
    {
        log("\nstorage class specifier static");
    }
    | AUTO
    {
        log("\nstorage class specifier auto");
    }
    | REGISTER
    {
        log("\nstorage class specifier register");
    }
    ;

type_specifier
    : VOID
    {
        log("\ntype specifier void");
    }
    | CHAR
    {
        log("\ntype specifier char");
    }
    | SHORT
    {
        log("\ntype specifier short");
    }
    | INT
    {
        log("\ntype specifier int");
    }
    | LONG
    {
        log("\ntype specifier long");
    }
    | FLOAT
    {
        log("\ntype specifier float");
    }
    | DOUBLE
    {
        log("\ntype specifier double");
    }
    | SIGNED
    {
        log("\ntype specifier signed");
    }
    | UNSIGNED
    {
        log("\ntype specifier unsigned");
    }
    | BOOL
    {
        log("\ntype specifier bool");
    }
    | COMPLEX
    {
        log("\ntype specifier complex");
    }
    | IMAGINARY
    {
        log("\ntype specifier imaginary");
    }
    | struct_or_union_specifier
    {
        log("\ntype specifier struct or union");
    }
    | enum_specifier
    {
        log("\ntype specifier enume");
    }
    | TYPE_NAME
    {
       log("type specifier type name\n");
    }
    ;

struct_or_union_specifier
    : struct_or_union IDENTIFIER '{' struct_declaration_list '}'
    {
        log("\nstruct or union specifier 1");
    }
    | struct_or_union '{' struct_declaration_list '}'
    {
        log("\nstruct or union specifier 2");
    }
    | struct_or_union IDENTIFIER
    {
        log("\nstruct or union specifier 3");
    }
    ;

struct_or_union
    : STRUCT
    {
        log("\nstruct or union 1");
    }
    | UNION
    {
        log("\nstruct or union 2");
    }
    ;

struct_declaration_list
    : struct_declaration
    {
        log("\nstruct declaration list 1");
    }
    | struct_declaration_list struct_declaration
    {
        log("\nstruct declaration list 2");
    }
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list ';'
    {
        log("\nstruct declaration");
    }
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list
    {
        log("\nspecifier qualifier list 1");
    }
    | type_specifier
    {
        log("\nspecifier qualifier list 2");
    }
    | type_qualifier specifier_qualifier_list
    {
        log("\nspecifier qualifier list 3");
    }
    | type_qualifier
    {
        log("\nspecifier qualifier list 4");
    }
    ;

struct_declarator_list
    : struct_declarator
    {
        log("\nstruct declarator list 1");
    }
    | struct_declarator_list ',' struct_declarator
    {
        log("\nstruct declarator list 2");
    }
    ;

struct_declarator
    : declarator
    {
        log("\nstruct declarator 1");
    }
    | ':' constant_expression
    {
        log("\nstruct declarator 2");
    }
    | declarator ':' constant_expression
    {
        log("\nstruct declarator 3");
    }
    ;

enum_specifier
    : ENUM '{' enumerator_list '}'
    {
        log("\nenum specifier 1");
    }
    | ENUM IDENTIFIER '{' enumerator_list '}'
    {
        log("\nenum specifier 2");
    }
    | ENUM '{' enumerator_list ',' '}'
    {
        log("\nenum specifier 3");
    }
    | ENUM IDENTIFIER '{' enumerator_list ',' '}'
    {
        log("\nenum specifier 4");
    }
    | ENUM IDENTIFIER
    {
        log("\nenum specifier 5");
    }
    ;

enumerator_list
    : enumerator
    {
        log("\nenumerator list 1");
    }
    | enumerator_list ',' enumerator
    {
        log("\nenumerator list 2");
    }
    ;

enumerator
    : IDENTIFIER
    {
        log("\nenumerator 1");
    }
    | IDENTIFIER '=' constant_expression
    {
        log("\nenumerator 2");
    }
    ;

type_qualifier
    : CONST
    {
        log("\ntype qualifier 1");
    }
    | RESTRICT
    {
        log("\ntype qualifier 2");
    }
    | VOLATILE
    {
        log("\ntype qualifier 3");
    }
    ;

function_specifier
    : INLINE
    {
        log("\nfunction specifier");
    }
    ;

declarator
    : pointer direct_declarator
    {
        log("\ndeclarator 1");
    }
    | direct_declarator
    {
        log("\ndeclarator 2");
    }
    ;


direct_declarator
    : IDENTIFIER
    {
        log("\ndirect declarator 1 - identifier '%s'",$1);
    }
    | '(' declarator ')'
    {
        log("\ndirect declarator 2");
    }
    | direct_declarator '[' type_qualifier_list assignment_expression ']'
    {
        log("\ndirect declarator 3");
    }
    | direct_declarator '[' type_qualifier_list ']'
    {
        log("\ndirect declarator 4");
    }
    | direct_declarator '[' assignment_expression ']'
    {
        log("\ndirect declarator 5");
    }
    | direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
    {
        log("\ndirect declarator 6");
    }
    | direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
    {
        log("\ndirect declarator 7");
    }
    | direct_declarator '[' type_qualifier_list '*' ']'
    {
        log("\ndirect declarator 8");
    }
    | direct_declarator '[' '*' ']'
    {
        log("\ndirect declarator 9");
    }
    | direct_declarator '[' ']'
    {
        log("\ndirect declarator 10");
    }
    | direct_declarator '(' parameter_type_list ')'
    {
        log("\ndirect declarator 11");
    }
    | direct_declarator '(' identifier_list ')'
    {
        log("\ndirect declarator 12");
    }
    | direct_declarator '(' ')'
    {
        log("\ndirect declarator 13");
    }
    ;

pointer
    : '*'
    {
        log("\npointer 1");
    }
    | '*' type_qualifier_list
    {
        log("\npointer 2");
    }
    | '*' pointer
    {
        log("\npointer 3");
    }
    | '*' type_qualifier_list pointer
    {
        log("\npointer 4");
    }
    ;

type_qualifier_list
    : type_qualifier
    {
        log("\ntype qualifier list 1");
    }
    | type_qualifier_list type_qualifier
    {
        log("\ntype qualifier list 2");
    }
    ;


parameter_type_list
    : parameter_list
    {
        log("\nparameter type list 1");
    }
    | parameter_list ',' ELLIPSIS
    {
        log("\nparameter type list 2");
    }
    ;

parameter_list
    : parameter_declaration
    {
        log("\nparameter list 1");
    }
    | parameter_list ',' parameter_declaration
    {
        log("\nparameter list 2");
    }
    ;

parameter_declaration
    : declaration_specifiers declarator
    {
        log("\nparameter declaration 1");
    }
    | declaration_specifiers abstract_declarator
    {
        log("\nparameter declaration 2");
    }
    | declaration_specifiers
    {
        log("\nparameter declaration 3");
    }
    ;

identifier_list
    : IDENTIFIER
    {
        log("\nidentifier list 1");
    }
    | identifier_list ',' IDENTIFIER
    {
        log("\nidentifier list 2");
    }
    ;

type_name
    : specifier_qualifier_list
    {
        log("\ntype name 1");
    }
    | specifier_qualifier_list abstract_declarator
    {
        log("\ntype name 2");
    }
    ;

abstract_declarator
    : pointer
    {
        log("\nabstract declarator 1");
    }
    | direct_abstract_declarator
    {
        log("\nabstract declarator 2");
    }
    | pointer direct_abstract_declarator
    {
        log("\ndirect abstract declarator 3");
    }
    ;

direct_abstract_declarator
    : '(' abstract_declarator ')'
    {
        log("\ndirect abstract declarator 1");
    }
    | '[' ']'
    {
        log("\ndirect abstract declarator 2");
    }
    | '[' assignment_expression ']'
    {
        log("\ndirect abstract declarator 3");
    }
    | direct_abstract_declarator '[' ']'
    {
        log("\ndirect abstract declarator 4");
    }
    | direct_abstract_declarator '[' assignment_expression ']'
    {
        log("\ndirect abstract declarator 5");
    }
    | '[' '*' ']'
    {
        log("\ndirect abstract declarator 6");
    }
    | direct_abstract_declarator '[' '*' ']'
    {
        log("\ndirect abstract declarator 7");
    }
    | '(' ')'
    {
        log("\ndirect abstract declarator 8");
    }
    | '(' parameter_type_list ')'
    {
        log("\ndirect abstract declarator 9");
    }
    | direct_abstract_declarator '(' ')'
    {
        log("\ndirect abstract declarator 10");
    }
    | direct_abstract_declarator '(' parameter_type_list ')'
    {
        log("\ndirect abstract declarator 11");
    }
    ;

initializer
    : assignment_expression
    {
        log("\ninitializer 1");
    }
    | '{' initializer_list '}'
    {
        log("\ninitializer 2");
    }
    | '{' initializer_list ',' '}'
    {
        log("\ninitializer 3");
    }
    ;

initializer_list
    : initializer
    {
        log("\ninitializer list 1");
    }
    | designation initializer
    {
        log("\ninitializer list 2");
    }
    | initializer_list ',' initializer
    {
        log("\ninitializer list 3");
    }
    | initializer_list ',' designation initializer
    {
        log("\ninitializer list 4");
    }
    ;

designation
    : designator_list '='
    {
        log("\ndesignation");
    }
    ;

designator_list
    : designator
    {
        log("\ndesignator list 1");
    }
    | designator_list designator
    {
        log("\ndesignator list 2");
    }
    ;

designator
    : '[' constant_expression ']'
    {
        log("\ndesignator 1");
    }
    | '.' IDENTIFIER
    {
        log("\ndesignator 2");
    }
    ;

statement
    : labeled_statement
    {
        log("\nstatement 1");
    }
    | compound_statement
    {
        log("\nstatement 2");
    }
    | expression_statement
    {
        log("\nstatement 3");
    }
    | selection_statement
    {
        log("\nstatement 4");
    }
    | iteration_statement
    {
        log("\nstatement 5");
    }
    | jump_statement
    {
        log("\nstatement 6");
    }
    ;

labeled_statement
    : IDENTIFIER ':' statement
    {
        log("\nlabeled statement 1");
    }
    | CASE constant_expression ':' statement
    {
        log("\nlabeled statement 2");
    }
    | DEFAULT ':' statement
    {
        log("\nlabeled statement 3");
    }
    ;

compound_statement
    : '{' '}'
    {
        log("\ncompound statement 1");
    }
    | '{' block_item_list '}'
    {
        log("\ncompound statement 2");
    }

    ;

block_item_list
    : block_item
    {
        log("\nblock item list 1");
    }
    | block_item_list block_item
    {
        log("\nblock item list 2");
    }
    ;

block_item
    : declaration
    {
        log("\nblock item 1");
    }
    | statement
    {
        log("\nblock item 2");
    }
    ;

expression_statement
    : ';'
    {
        log("\nexpression statement 1");
    }
    | expression ';'
    {
        log("\nselection statement 2");
    }
    ;

selection_statement
    : IF '(' expression ')' statement
    {
        log("\nselection statement 1");
    }
    | IF '(' expression ')' statement ELSE statement
    {
        log("\nselection statement 2");
    }
    | SWITCH '(' expression ')' statement
    {
        log("\nselection statement 3");
    }
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    {
        log("\nIteration statement 1");
    }
    | DO statement WHILE '(' expression ')' ';'
    {
        log("\nIteration statement 2");
    }
    | FOR '(' expression_statement expression_statement ')' statement
    {
        log("\nIteration statement 3");
    }
    | FOR '(' expression_statement expression_statement expression ')' statement
    {
        log("\nIteration statement 4");
    }
    | FOR '(' declaration expression_statement ')' statement
    {
        log("\nIteration statement 5");
    }
    | FOR '(' declaration expression_statement expression ')' statement
    {
        log("\nIteration statement 6");
    }
    ;

jump_statement
    : GOTO IDENTIFIER ';'
    {
        log("\nJump statement 1");
    }
    | CONTINUE ';'
    {
        log("\nJump statement 2");
    }
    | BREAK ';'
    {
        log("\nJump statement 3");
    }
    | RETURN ';'
    {
        log("\nJump statement 4");
    }
    | RETURN expression ';'
    {
        log("\nJump statement 5");
    }
    ;

translation_unit
    : external_declaration
    {
        log("\nTranslation unit 1");
    }
    | translation_unit external_declaration
    {
        log("\nTranslation unit 2");
    }
    ;

external_declaration
    : function_definition
    {
        log("\nExternal declaration 1");
    }
    | declaration
    {
        log("\nExternal declaration 2");
    }
    ;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement
    {
        log("\nFunction definition 1");
    }
    | declaration_specifiers declarator compound_statement
    {
        log("\nFunction definition 2");
    }
    ;

declaration_list
    : declaration
    {
        log("\nDeclaration list 1");
    }
    | declaration_list declaration
    {
        log("\nDeclaration list 2");
    }
    ;


%%
#include <stdio.h>

extern char yytext[];
extern int column;

void yyerror(char const *s)
{
    fflush(stdout);
    printf("\n%*s\n%*s\n", column, "^", column, s);
}
