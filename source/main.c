#define _GNU_SOURCE
#include <stdio.h>
#include <stdarg.h>

#include "tbsp.yy.h"
#include "tbsp.tab.h"

#include "cli.h"

// XXX i am so desperate for #embed, you would not believe
#include "TBSP_strings.inc"

#define CHECKED_FOPEN(target, filename, mode) do {\
    target = fopen(filename, mode);\
    if (!target) {\
        yyerror("failed to open '%s'", filename);\
        return 1;\
    }\
} while (0)

extern int tbsp_yy_init(void);
extern int tbsp_yy_deinit(void);
extern int tbsp_c_yy_init(void);
extern int tbsp_c_yy_deinit(void);

char * language = NULL;
char * verbatim = NULL;
char * top = NULL;

void yyerror(const char * const fmt, ...) {
    extern int yylineno;
    va_list args;
    va_start(args, fmt);

    fprintf(stderr, "%s:%d: error: ", input_file_name, yylineno);
    vfprintf(stderr, fmt, args);
    fputc('\n', stderr);

    va_end(args);
}

static
void dump_rule_table(const char * const name, rule_type_t type_mask) {
    char * sprint_buffer;
    int sprint_r;
    (void)sprint_r;
    fputs("const tbcase_t tb", yyout);
    fputs(name, yyout);
    fputs("[] = {\n", yyout);
    for (int i = 0; i < kv_size(rules); i++) {
        if (!(kv_A(rules, i).type & type_mask)) { continue; }
        sprint_r = asprintf(&sprint_buffer,
                                TBSP_case,
                                kv_A(rules, i).string,
                                kv_A(rules, i).target
        );
        fputs(sprint_buffer, yyout);
        free(sprint_buffer);
    }
    fputs("    (tbcase_t) { .string = NULL, .case_number = 0 },\n", yyout);
    fputs("};\n\n", yyout);
}

static
void dump_output(void) {
    char * sprint_buffer;
    int sprint_r;
    (void)sprint_r;

    // Header
    sprint_r = asprintf(&sprint_buffer, TBSP_header, language, language);
    fputs(sprint_buffer, yyout);
    free(sprint_buffer);

    // Definition section
    if (top) {
        fputs(top, yyout);
    }
   
    // Rule section
    dump_rule_table("enter_cases", ENTER_RULE);
    dump_rule_table("leave_cases", LEAVE_RULE);

    fputs(TBSP_traverse_top, yyout);
    for (int i = 0; i < kv_size(rules); i++) {
        const char * const case_string = "\
            case %d: {\n\
                %s\n\
            } break;\n\
        ";
        sprint_r = asprintf(&sprint_buffer,
                                case_string,
                                kv_A(rules, i).target,
                                kv_A(rules, i).code
        );
        fputs(sprint_buffer, yyout);
        free(sprint_buffer);
    }
    fputs(TBSP_traverse_bottom, yyout);

    // Code section
    fputs(verbatim, yyout);
}

static inline
void init(void) {
    tbsp_yy_init();
    tbsp_tab_init();
    tbsp_c_yy_init();
}

static inline
void deinit(void) {
    for (int i = 0; i < kv_size(rules); i++) {
        free(kv_A(rules, i).string);
        free(kv_A(rules, i).code);
    }
    tbsp_yy_deinit();
    tbsp_c_yy_deinit();
    free(output_file_name);
    free(input_file_name);
    free(verbatim);
    free(language);
    free(top);
}

signed main(const int argc, const char * const * const argv) {
  #ifdef DEBUG
    yydebug = 1;
  #endif

    if (handle_arguments(argc, argv)) { return 1; }

    init();

    CHECKED_FOPEN(yyin,  input_file_name,  "r");

    int yyparse_r = yyparse();
    if (yyparse_r) { return yyparse_r; }

    CHECKED_FOPEN(yyout, output_file_name, "w");

    dump_output();

    deinit();

    return 0;
}
