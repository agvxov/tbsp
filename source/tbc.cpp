#include <stdio.h>
#include <string.h>
extern "C" {
    #include <tree_sitter/api.h>
    extern const TSLanguage * tree_sitter_c(void);
}

int tbtraverse(const char * const code) {
    // init
    TSParser * parser;
    TSTree * tree;
    TSTreeCursor cursor;
    TSNode current_node;
    TSNode previous_node;

    parser = ts_parser_new();

    ts_parser_set_language(parser, tree_sitter_c());

    tree = ts_parser_parse_string(parser, NULL, code, strlen(code));
    cursor = ts_tree_cursor_new(ts_tree_root_node(tree));
    current_node = ts_tree_root_node(tree);

    // meat
    do {
        current_node = ts_tree_cursor_current_node(&cursor);

		const char * previous_node_type = NULL;

		int tblen = ts_node_end_byte(current_node) - ts_node_start_byte(current_node);
		char * tbtext = (char *)malloc(sizeof(char) * (tblen + 1));
		memcpy(tbtext, code + ts_node_start_byte(current_node), tblen);
		tbtext[tblen] = '\0';

		// XXX INJECTION
		
        if (!strcmp("function_definition", ts_node_type(current_node))) {
			
			puts("ack");
			puts(tbtext);

			goto end;
        }


        if (!strcmp("number_literal", ts_node_type(current_node))) {
			
			puts("++");

			goto end;
        }



	  end:
		free(tbtext);
    } while ([&] {
		bool r = false;
		previous_node = current_node;

        if (ts_tree_cursor_goto_first_child(&cursor)
        ||  ts_tree_cursor_goto_next_sibling(&cursor)) {
            r = true;
			goto eval;
        }
		
		while (ts_tree_cursor_goto_parent(&cursor)) {
			if (!strcmp(ts_node_type(current_node), "translation_unit")) {
				r = false;
				break;
			}

			if (ts_tree_cursor_goto_next_sibling(&cursor)) {
				r = true;
			}

		  eval:
			if (!strcmp("function_definition", ts_node_type(previous_node))) {
				puts("^^df");

				goto end;
			}

		  end:
			if (r) { break; }
		}

		return r;
    }());

    // deinit
    ts_tree_delete(tree);
    ts_parser_delete(parser);
    ts_tree_cursor_delete(&cursor);

    return 0;
}


// @BAKE g++ $@ $(pkg-config --cflags --libs tree-sitter tree-sitter-c) -ggdb

signed main() {
    tbtraverse("int main() { return 0; }");
}

