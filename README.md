# TBSP
> Tree-Based Source-Processing language

## Notes
I stole the idea from here:
[https://github.com/oppiliappan/tbsp](https://github.com/oppiliappan/tbsp)

Now, there are some obvious problems with this project:
+ its written in rust
+ it tries to be a general purpose language for no reason
+ >"[ ] bytecode VM?"; serious?

I have tried contacting the owner, the response is pending.

I have tried hacking Bison into this behaviour, its too noisy.

I firmly believe code generation is the way to go, not just here,
but for DSL-es in general.

This project will heavy depend on tree-sitter,
there is no sense pretending otherwise with decoupling.

The current implementation (in python) is obviously terrible.
It does work however.

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
enter <node-type> { <...> } // code to run when tree-sitter node-type <node-type> is encountered
close <node-type> { <...> } // code to run when tree-sitter node-type <node-type> is poped from
```

### Code
The code section is verbatim pasted to the end of the output file.
#### Globals
```C
int tbtraverse(const char * const code);    // master function; rules are evaluated here
```
#### In tbtraverse
```C
char * tbtext;   // copy of the current nodes text value (not ts_node_string); XXX: this could be much optimized
int tblen;       // string lenght of tbtext
// XXX: these should probably be renamed
TSNode current_node;    // node corresponding to the rule in enter rules
TSNode previous_node;   // node corresponding to the rule in close rules
```

### TODO
+ port "backend" to C (from C++)
+ port from python (can wait)
  - optimize the allocation of tbtext
  - optimize from strcmp()

### Thinking area
```C
// This should be allowed to mean 'a' or 'b'
enter a b { <...> }

// This should be allowed to mean 'enter' or 'leave'
enter leave a { <...> }

// In node type blobbing should probably be allowed, however regex sounds like overkill
```
