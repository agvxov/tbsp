%{
    #include "tbsp.yy.h"
    #include <kvec.h>

    int target_counter = 1;

    kvec_t(char *) rule_selectors;

    char * language = NULL;
    char * verbatim = NULL;
    char * top = NULL;

    #define COMA ,
%}
%code requires {
    #include "rule.h"
    extern void yyerror(const char * const s, ...);
}
%code provides {
    void tbsp_tab_init(void);
    void tbsp_tab_deinit(void);

    extern rule_vector_t rules;

    extern char * language;
    extern char * top;
    extern char * verbatim;
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
%%
document
    : %empty
    | definition_section SEPARATOR rule_section SEPARATOR code_section
    ;

definition_section
    : definition_section_primitive {
        if (!language) {
            yyerror("no %%language statement found, but a language is required");
            return 1;
        }
    }
    ;

definition_section_primitive
    : %empty
    | top definition_section
    | language definition_section
    ;

top
    : TOP CODE_BLOB {
        if (top) {
            yyerror("multiple %%top statements found, but only one is allowed");
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
        extern int tbsp_c_yy_reset(void);
        extern char * tbsp_c_expland_code(const char * const s);

        char * code_blob_expanded = strdup(tbsp_c_expland_code($3));

        kv_push(code_t, codes, (code_t) {
            .number = target_counter++ COMA
            .code = code_blob_expanded COMA
        });

        for (int i = 0; i < kv_size(rule_selectors); i++) {
            kv_push(rule_t, rules, (rule_t) {
                .type       = $1 COMA
                .string     = kv_A(rule_selectors, i) COMA
                .code_index = codes.n-1 COMA
            });
        }

        rule_selectors.n = 0;
        tbsp_c_yy_reset();
        free($3);
    }
    ;

rule_type
    : %empty { $$ = 0; }
    | ENTER rule_type { $$ |= ENTER_RULE; }
    | LEAVE rule_type { $$ |= LEAVE_RULE; }
    ;

rule_selector
    : IDENTIFIER { 
        kv_push(char *, rule_selectors, $1);
    }
    | IDENTIFIER rule_selector {
        kv_push(char *, rule_selectors, $1);
    }
    ;


code_section
    : CODE_BLOB {
        verbatim = $1;
    }
    ;
%%

rule_vector_t rules;
code_vector_t codes;

void tbsp_tab_init(void) {
    kv_init(rules);
    kv_init(codes);
    kv_init(rule_selectors);
}

void tbsp_tab_deinit(void) {
    for (int i = 0; i < kv_size(rule_selectors); i++) {
        free(kv_A(rule_selectors, i));
    }

    for (int i = 0; i < kv_size(codes); i++) {
        free(kv_A(codes, i).code);
    }

    for (int i = 0; i < kv_size(rules); i++) {
        free(kv_A(rules, i).string);
    }

    kv_destroy(rules);
    kv_destroy(codes);
    kv_destroy(rule_selectors);

    free(verbatim);
    free(language);
    free(top);
}
