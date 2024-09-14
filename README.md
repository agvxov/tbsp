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
int tbtraverse(const char * const code);    // master function; rules are evaluated here
```
#### In tbtraverse
```C
GET_TBTEXT;              // macro that returns a `char *` to the current node's text value (not ts_node_string); its the programmers responsibility to free() it
GET_TBTEXT_FROM_NODE(x); // macro that returns a `char *` to the passed in node's text value (not ts_node_string); its the programmers responsibility to free() it
int tblen;       // string lenght of tbtext; XXX probably broken?
// XXX: these should probably be renamed
TSNode current_node;    // node corresponding to the rule
// XXX need a macro bool for leave/enter
```
