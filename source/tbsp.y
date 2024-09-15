%{
    #include "tbsp.yy.h"

    extern char * language;
    extern char * top;
    extern char * verbatim;

    int target_counter = 1;

    #define COMA ,
%}
%code requires {
    typedef enum {
        ENTER_RULE = 0b0001,
        LEAVE_RULE = 0b0010,
    } rule_type_t;

    typedef struct {
        rule_type_t type;
        int target;
        char * string;
        char * code;
    } rule_t;

    #include <kvec.h>
    typedef kvec_t(rule_t) rule_vector_t;
    extern rule_vector_t rules;

    extern void yyerror(const char * const s, ...);
}
%code provides {
    void tbsp_tab_init(void);
    void tbsp_tab_deinit(void);
}
%union{
    char * strval;
    rule_type_t ruleval;
}
%token SEPARATOR
%token TOP LANGUAGE
%token ENTER LEAVE
%token<strval> IDENTIFIER CODE_BLOB
%type<ruleval> rule_type
%type<strval> rule_selector
%%
document
    : %empty
    | definition_section SEPARATOR rule_section SEPARATOR code_section
    ;

definition_section
    : %empty
    | top definition_section
    | language definition_section
    ;

top
    : TOP CODE_BLOB {
        if (top) {
            puts("error: reee");
            return 1;
        }
        top = $2;
    }
    ;

language
    : LANGUAGE IDENTIFIER {
        language = $2;
    }
    ;

rule_section
    : %empty
    | rule rule_section
    ;

rule
    : rule_type rule_selector CODE_BLOB {
        extern char * tbsp_c_expland_code(const char * const s);
        char * code_blob_expanded = strdup(tbsp_c_expland_code($3));

        kv_push(rule_t, rules, (rule_t) {
            .type   = $1 COMA
            .target = target_counter COMA
            .string = $2 COMA
            .code   = code_blob_expanded COMA
        });
        ++target_counter;
    }
    ;

rule_type
    : %empty { $$ = 0; }
    | ENTER rule_type { $$ |= ENTER_RULE; }
    | LEAVE rule_type { $$ |= LEAVE_RULE; }
    ;

rule_selector
    : IDENTIFIER { $$ = $1; }
    ;


code_section
    : CODE_BLOB {
        verbatim = $1;
    }
    ;
%%

rule_vector_t rules;

void tbsp_tab_init(void) {
    kv_init(rules);
}

void tbsp_tab_deinit(void) {
    for (int i = 0; i < kv_size(rules); i++) {
        free(kv_A(rules, i).string);
        free(kv_A(rules, i).code);
    }

    kv_destroy(rules);
}
