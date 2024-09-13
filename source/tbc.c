#include <stdio.h>
#include <string.h>

#include <tree_sitter/api.h>
extern const TSLanguage * tree_sitter_c(void);

typedef struct {
    const char * const string;
    const int case_number;
} tbcase_t;

const tbcase_t tb_enter_cases[] = {
    (tbcase_t) { .string = "function_definition", .case_number = 1 },
    (tbcase_t) { .string = "number_literal", .case_number = 2 },
    (tbcase_t) { .string = NULL, .case_number = 0 },
};

const tbcase_t tb_leave_cases[] = {
    (tbcase_t) { .string = "function_definition", .case_number = 3 },
    (tbcase_t) { .string = NULL, .case_number = 0 },
};

// XXX better search algo
int determine_case(const tbcase_t * const ordered_array, const char * const string) {
    const tbcase_t * c = ordered_array;
    for (; c->string != NULL; c++) {
        if (!strcmp(c->string, string)) { break; }
    }

    return c->case_number;
}

char * tbtext(const char * const code, TSNode node) {
    int tblen = ts_node_end_byte(node) - ts_node_start_byte(node);
    char * r = (char *)malloc(sizeof(char) * (tblen + 1));

    memcpy(r, code + ts_node_start_byte(node), tblen);
    r[tblen] = '\0';

    return r;
}

#define GET_TBTEXT tbtext(code, current_node)

int tbtraverse(const char * const code) {
    // init
    TSParser * parser;
    TSTree * tree;
    TSTreeCursor cursor;
    TSNode current_node;

    int tb_case;

    parser = ts_parser_new();

    ts_parser_set_language(parser, tree_sitter_c());

    tree = ts_parser_parse_string(parser, NULL, code, strlen(code));
    cursor = ts_tree_cursor_new(ts_tree_root_node(tree));
    current_node = ts_tree_root_node(tree);

    // meat
    while (true) {
        current_node = ts_tree_cursor_current_node(&cursor);

        tb_case = determine_case(tb_enter_cases, ts_node_type(current_node));

        // XXX INJECTION
      eval:
        switch (tb_case) {
            case 1: {
                puts("ack");
                char * mytbtext = GET_TBTEXT;
                puts(mytbtext);
                free(mytbtext);
            } break;
            case 2: {
                puts("++");
            } break;
            case 3: {
                puts("^^df");
            } break;
            default: { ; } break;
        }

        if (ts_tree_cursor_goto_first_child(&cursor)
        ||  ts_tree_cursor_goto_next_sibling(&cursor)) {
            continue;
        }

        while (ts_tree_cursor_goto_parent(&cursor)) {
            current_node = ts_tree_cursor_current_node(&cursor);
            if (ts_tree_cursor_goto_next_sibling(&cursor)) {
                tb_case = determine_case(tb_leave_cases, ts_node_type(current_node));
                goto eval;
            }
        }

        break;
    }

    // deinit
    ts_tree_delete(tree);
    ts_parser_delete(parser);
    ts_tree_cursor_delete(&cursor);

    return 0;
}


// @BAKE gcc $@ $(pkg-config --cflags --libs tree-sitter tree-sitter-c) -ggdb

signed main() {
    tbtraverse("int main() { return 0; }");
}

