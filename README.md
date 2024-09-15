# TBSP
> Tree-Based Source-Processing language

## Language semantics
TBSP is a DSL which extends a backend language.
It has a small syntax which was designed after Flex/Bison
with the goal of reducing noise in programs using tree-sitter.

The only currently supported backend is C/C++.
```
<declaration-section>
%%
<rule-section>
%%
<code-section>
```

Example:
```
%language c
%%
enter translation_unit {
    puts("Hello World!");
}
%%
// @BAKE tbsp $@; gcc hello_world.tb.c $(pkg-config --libs tree-sitter tree-sitter-c); ./a.out
signed main(void) {
    tbtraverse("int i = 0;");
    return 0;
}
```
The above is a fully functional tbsp program.
`tbtraverse()` will print `"Hello World!"` given any code.

NOTE: "@BAKE" is this tool here: https://github.com/emilwilliams/bake

### Declaration section
```
%top { <...> }    // code to be pasted at the top of the source file
%language <lang>  // tree-sitter langauge name (for the right includes)
```

### Rule section
The rule section is composed of any number of Rules.
```C
/* A Rule
 *   + enter : signals that the rule applies when a node is pushed
 *   + leave : signals that the rule applies when a node is popped
 * 'leave' and 'enter' may be specified at the same time,
 *  the rule fill run on both pushes and pops.
 * <node-type> is the name of a tree-sitter node type.
 *  The rule will run only if such node is encountered.
 * <...> is the code associated with the rule.
 *  Its provided in the backend language.
 */
[enter|leave]+ <node-type> { <...> }
```

### Code
The code section is verbatim pasted to the end of the output file.
#### Globals
```C
/* Master function.
 * Rules are evaluated inside here.
 * Returns 0 on normal exit.
 */
int tbtraverse(const char * const code);
```
#### In tbtraverse
```C
/* Rules are guaranteed to be inside tbtraverse(),
 *  this means that you may return from rules.
 */
return 0;

/* Node corresponding to the rule being evaluated
 */
TSNode tbnode;

/* Macro that returns a `char *` to the tbnode's text value.
 * Not equivalent to ts_node_string().
 * Its the programmers responsibility to free() it.
 */
char * tbget_text;

/* Macro that returns a `char *` to the x's text value.
 * Not equivalent to ts_node_string().
 * Its the programmers responsibility to free() it.
 */
char * tbget_node_text(x);

/* Macro signalling whether we are executing as an enter rule.
 * Could be useful for shared rules.
 */
bool tbis_enter;
```
