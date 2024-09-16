#ifndef RULE_H
#define RULE_H

#include <kvec.h>

typedef enum {
    ENTER_RULE = 0b0001,
    LEAVE_RULE = 0b0010,
} rule_type_t;

typedef struct {
    int number;
    char * code;
} code_t;

typedef struct {
    rule_type_t type;
    char * string;
    int code_index;
} rule_t;

typedef kvec_t(rule_t) rule_vector_t;
extern rule_vector_t rules;

typedef kvec_t(code_t) code_vector_t;
extern code_vector_t codes;

#endif
