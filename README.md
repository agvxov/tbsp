# TBSP
> Tree-Based Source-Processing language

## Notes
I stole the idea from here:
[https://github.com/oppiliappan/tbsp](https://github.com/oppiliappan/tbsp)

Now, there are some obvious problems with this project:
+ its written in rust
+ it tries to be a general purpose language for no reason
+ >"[ ] bytecode VM?"; seriously?

I have tried contacting the owner, the response is pending.

I have tried hacking Bison into this behaviour, its too noisy.

I firmly believe code generation is the way to go, not just here,
but for DSL-es in general.

This project will heavy depend on tree-sitter,
there is no sense pretending otherwise with decoupling.

## Language semantics
Modelled half after the original, half after Flex/Bison.
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
[enter|close]+ <node-type> { <...> } // code to run when tree-sitter node-type <node-type> is encountered/popped from
```

### Code
The code section is verbatim pasted to the end of the output file.
#### Globals
```C
int tbtraverse(const char * const code);    // master function; rules are evaluated here
```
#### In tbtraverse
```C
GET_TBTEXT;      // macro that returns a `char *` to the current node's text value (not ts_node_string); its the programmers responsibility to free() it
int tblen;       // string lenght of tbtext; XXX probably broken?
// XXX: these should probably be renamed
TSNode current_node;    // node corresponding to the rule
// XXX need a macro bool for leave/enter
```

### Thinking area
```C
// This should be allowed to mean 'a' or 'b'
enter a b { <...> }

// In the node type, blobbing should probably be allowed, however regex sounds like overkill

/* A query language should also exist
 *   $0-><name>
 * Where <name> is the named field of the rules node.
 * The reason something like this could be useful is because
 *  if such queries are performed by hand, they can easily segv if not checked,
 *  however, because of the required checking they are very non-ergonomic.
 * For error handling, say something this could be employed:
 *   enter a { ; } catch { ; }
 * Where 'catch' could be implemented as a goto.
 * I am unsure whether this would be too generic to be useful or not.
 */
```
