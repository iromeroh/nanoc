#ifndef __PARSER_H
#define __PARSER_H

#define INT_LITERAL 1
#define CHAR_LITERAL 2
#define FLOAT_LITERAL 3
#define STR_LITERAL 4
#define ID_NAME 5

#define ARRAY_INDEX_SEM 6
#define FUNC_CALL_SEM   7
#define FUNC_CALL_NOPARAMS_SEM   8
#define STRUCT_SELECT_SEM 9
#define STRUCT_PTR_SELECT_SEM 10
#define POSTFIX_INC_SEM 11
#define POSTFIX_DEC_SEM 12
#define C99_WEIRD_SEM1 13
#define C99_WEIRD_SEM2 14
#define ARGUMENT_COMMA_SEM 15
#define PREFIX_INC_SEM 16
#define PREFIX_DEC_SEM 17
#define CONCRETE_UNARY_OP_SEM 18
#define SIZEOF_TYPE_SEM 19
#define SIZEOF_SEM 20
#define AMPERSAND 21
#define ASTERISK 22
#define PLUS 23
#define MINUS 24
#define TILDE 25
#define EXCLAMATION 26
#define CAST_EXPR_SEM 27
#define MULTIPLICATE_SEM 29
#define DIVIDE_SEM 30
#define MODULO_SEM 31
#define ADDITION_SEM 32
#define REST_SEM 33
#define LSHIFT_SEM 34
#define RSHIFT_SEM 35
#define LESS_THAN_SEM 36
#define GREATER_THAN_SEM 37
#define LESS_OR_EQUAL_SEM 38
#define GREATER_OR_EQUAL_SEM 39
#define EQUALS_SEM 40
#define NOT_EQUALS_SEM 41
#define AND_SEM 42
#define XOR_SEM 43
#define OR_SEM 44
#define LOGIC_AND_SEM 45
#define LOGIC_OR_SEM 46
#define CONDITIONAL_EXPR_SEM 47
#define ASSIGN_SEM 48
#define MUL_ASSIGN_SEM 49
#define DIV_ASSIGN_SEM 50
#define MOD_ASSIGN_SEM 51
#define ADD_ASSIGN_SEM 52
#define SUB_ASSIGN_SEM 53
#define LEFT_ASSIGN_SEM 54
#define RIGHT_ASSIGN_SEM 55
#define AND_ASSIGN_SEM 56
#define XOR_ASSIGN_SEM 57
#define OR_ASSIGN_SEM 58


typedef struct NodeType{
    void * element;
    size_t n;
    struct NodeType * next;
}LinkedList;

typedef struct{
    int op;
    LinkedList * items;
} ExprType;

void error( const char* format, ... );

LinkedList * list_create(void *element, size_t n);
int len(LinkedList * head);
LinkedList * append(LinkedList * head, void *element, size_t n);
LinkedList * element_at(LinkedList * head, int i);
LinkedList * insert_after(LinkedList * node, void *element, size_t n);
LinkedList * insert_before(LinkedList * node, void *element, size_t n);

ExprType* expr_create(unsigned int op, LinkedList *items);

#endif
