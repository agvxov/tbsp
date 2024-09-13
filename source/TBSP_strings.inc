const char * const TBSP_header = "\
#include <stdio.h>\n\
#include <string.h>\n\
\n\
#include <tree_sitter/api.h>\n\
#ifdef __cplusplus\n\
extern \"C\" {\n\
#endif\n\
extern const TSLanguage * tree_sitter_%s(void);\n\
#ifdef __cplusplus\n\
}\n\
#endif\n\
const TSLanguage * (*tblanguage_function)(void) = tree_sitter_%s;\n\
\n\
typedef struct {\n\
	const char * const string;\n\
	const int case_number;\n\
} tbcase_t;\n\
\n\
// XXX better search algo\n\
int determine_case(const tbcase_t * const ordered_array, const char * const string) {\n\
    const tbcase_t * c = ordered_array;\n\
    for (; c->string != NULL; c++) {\n\
        if (!strcmp(c->string, string)) { break; }\n\
    }\n\
\n\
    return c->case_number;\n\
}\n\
\n\
char * tbtext(const char * const code, TSNode node) {\n\
    int tblen = ts_node_end_byte(node) - ts_node_start_byte(node);\n\
    char * r = (char *)malloc(sizeof(char) * (tblen + 1));\n\
\n\
    memcpy(r, code + ts_node_start_byte(node), tblen);\n\
    r[tblen] = '\\0';\n\
\n\
    return r;\n\
}\n\
\n\
#define GET_TBTEXT tbtext(code, current_node)\n\
";

const char * const TBSP_case = "\
    (tbcase_t) { .string = \"%s\", .case_number = %d },\n\
";

const char * const TBSP_traverse_top = "\
int tbtraverse(const char * const code) {\n\
    // init\n\
    TSParser * parser;\n\
    TSTree * tree;\n\
    TSTreeCursor cursor;\n\
    TSNode current_node;\n\
\n\
    int tb_case;\n\
\n\
    parser = ts_parser_new();\n\
\n\
    ts_parser_set_language(parser, tblanguage_function());\n\
\n\
    tree = ts_parser_parse_string(parser, NULL, code, strlen(code));\n\
    cursor = ts_tree_cursor_new(ts_tree_root_node(tree));\n\
    current_node = ts_tree_root_node(tree);\n\
\n\
    const tbcase_t * current_cases = tb_enter_cases;\n\
\n\
    // meat\n\
    while (true) {\n\
        current_node = ts_tree_cursor_current_node(&cursor);\n\
\n\
        tb_case = determine_case(current_cases, ts_node_type(current_node));\n\
\n\
        // XXX INJECTION\n\
      #if defined(TBDEBUG) && TBDEBUG == 1\n\
        puts(ts_node_string(current_node));\n\
      #endif\n\
        switch (tb_case) {\n\
";

const char * const TBSP_traverse_bottom = "\
                    default: { ; } break;\n\
        }\n\
\n\
        if (ts_node_child_count(current_node)\n\
        &&  current_cases == tb_enter_cases) {\n\
            ts_tree_cursor_goto_first_child(&cursor);\n\
            continue;\n\
        }\n\
\n\
      logic:\n\
        if (!ts_node_is_null(ts_node_next_sibling(current_node))) {\n\
            if (current_cases == tb_enter_cases) {\n\
                current_cases = tb_leave_cases;\n\
                continue;\n\
            } else {\n\
                ts_tree_cursor_goto_next_sibling(&cursor);\n\
                current_cases = tb_enter_cases;\n\
                continue;\n\
            }\n\
        }\n\
\n\
        if (current_cases == tb_enter_cases) {\n\
            current_cases = tb_leave_cases;\n\
            continue;\n\
        }\n\
\n\
        if (ts_tree_cursor_goto_parent(&cursor)) {\n\
            current_cases = tb_enter_cases;\n\
            goto logic;\n\
        }\n\
\n\
        break;\n\
    }\n\
\n\
    // deinit\n\
    ts_tree_delete(tree);\n\
    ts_parser_delete(parser);\n\
    ts_tree_cursor_delete(&cursor);\n\
\n\
    return 0;\n\
}\n\
";