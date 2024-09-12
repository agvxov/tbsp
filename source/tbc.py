# @BAKE python tbc.py convert.tbsp > kek.cpp
import re
import sys

def header(s : str, lang : str) -> str:
	r = s.format(language=lang)
	return r

def definition_section(s : str) -> str:
	def top(s : str) -> str:
		regex = re.compile(r"^%top {(.*?^)}", re.MULTILINE | re.DOTALL)
		matches = regex.findall(s)
		return matches[0]
	def lang(s : str) -> str:
		regex = re.compile(r"%language (\w+)", re.MULTILINE | re.DOTALL)
		matches = regex.findall(s)
		return matches[0]
	return {
		"code" : top(s),
		"language" : lang(s),
	}

def rule_section(s : str) -> str:
	def rules(s : str, p : r"", shim : str) -> str:
		r = ""
		regex = re.compile(p, re.MULTILINE | re.DOTALL)
		matches = regex.findall(s)
		l = []
		for match in matches:
			l.append({
				"name": match[0],
				"code": match[1][1:-1],
			})
		for i in l:
			r += shim.format(**i)
		return r
	enter_shims = rules(s, r"^enter (\w+) {(.*?)^}", shim_enter)
	leave_shims = rules(s, r"^leave (\w+) {(.*?)^}", shim_leave)
	r = tbtraverse.format(enter_shims=enter_shims, leave_shims=leave_shims)
	return r

def tbc_main(argv : [str]):
	if len(argv) < 2:
		print("tbc <file>")
		exit(1)

	input_file = argv[1]
	input_string = open(input_file, "r").read()

	delim = "%%"
	delims = []
	delims.append(input_string.find(delim))
	delims.append(delims[0] + len(delim) + input_string[delims[0]+len(delim):].find(delim))

	definition_data = definition_section(input_string[:delims[0]])

	print(header(header_str, definition_data["language"]))
	print(definition_data["code"])
	print(rule_section(input_string[delims[0]+len(delim):delims[1]]))
	print(input_string[delims[1]+len(delim):])

	return 0

# ------------------------------
# --- STRING LITERAL SECTION ---
# ------------------------------

header_str = '''
#include <stdio.h>
#include <string.h>
#include <tree_sitter/api.h>

extern "C" const TSLanguage * tree_sitter_{language}(void);

const TSLanguage * (*tree_sitter_language_function)(void) = tree_sitter_{language};
'''

tbtraverse = '''
int tbtraverse(const char * const code) {{
    // init
    TSParser * parser;
    TSTree * tree;
    TSTreeCursor cursor;
    TSNode current_node;
    TSNode previous_node;

    parser = ts_parser_new();

    ts_parser_set_language(parser, tree_sitter_language_function());

    tree = ts_parser_parse_string(parser, NULL, code, strlen(code));
    cursor = ts_tree_cursor_new(ts_tree_root_node(tree));
    current_node = ts_tree_root_node(tree);

    // meat
    do {{
        current_node = ts_tree_cursor_current_node(&cursor);

        int tblen = ts_node_end_byte(current_node) - ts_node_start_byte(current_node);
        char * tbtext = (char *)malloc(sizeof(char) * (tblen + 1));
        memcpy(tbtext, code + ts_node_start_byte(current_node), tblen);
        tbtext[tblen] = '\\0';

      #if defined(TBDEBUG) && TBDEBUG == 1
        puts(ts_node_string(current_node));
      #endif

        // XXX INJECTION
        {enter_shims}

      end:
        free(tbtext);
    }} while ([&](void) -> bool {{
        bool r = false;

        if (ts_tree_cursor_goto_first_child(&cursor)) {{
			return true;
		}}

        if (ts_tree_cursor_goto_next_sibling(&cursor)) {{
            r = true;
			previous_node = current_node;
            goto eval;
        }}
        
        while (ts_tree_cursor_goto_parent(&cursor)) {{
			previous_node = ts_tree_cursor_current_node(&cursor);
            if (ts_tree_cursor_goto_next_sibling(&cursor)) {{
                r = true;
            }}

          eval:
          #if defined(TBDEBUG) && TBDEBUG == 1
            puts(ts_node_string(previous_node));
          #endif

            // XXX INJECTION
            {leave_shims}

          end:
            if (r) {{ break; }}
        }}

        return r;
    }}());

    // deinit
    ts_tree_delete(tree);
    ts_parser_delete(parser);
    ts_tree_cursor_delete(&cursor);

    return 0;
}}
'''

shim_enter = '''
        if (!strcmp("{name}", ts_node_type(current_node))) {{
            {code}
            goto end;
        }}

'''

shim_leave = '''
        if (!strcmp("{name}", ts_node_type(previous_node))) {{
            {code}
            goto end;
        }}
'''

if __name__ == '__main__':
	exit(tbc_main(sys.argv))
