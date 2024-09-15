# TBSP
> Tree-Based Source-Processing language

XXX: sort out the name situation

## Language semantics
Flex/Bison like.
```
<declaration-section>
%%
<rule-section>
%%
<code-section>
```

### Declaration section
```
%top { <...> }    // code to be pasted at the top of the source file
%language <lang>  // tree-sitter langauge name (for the right includes)
```

### Rule section
```
[enter|leave]+ <node-type> { <...> } // code to run when tree-sitter node-type <node-type> is encountered/popped from
```

### Code
The code section is verbatim pasted to the end of the output file.
#### Globals
```C
/* Master function.
 * Rules are evaluated inside here.
 */
int tbtraverse(const char * const code);    // master function; rules are evaluated here
```
#### In tbtraverse
```C
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
