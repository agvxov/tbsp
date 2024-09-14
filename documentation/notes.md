# Notes

I stole the idea from here:
[https://github.com/oppiliappan/tbsp](https://github.com/oppiliappan/tbsp)

Now, there are some obvious problems with this project:
+ its written in rust
+ it tries to be a general purpose language for no reason
+ "[ ] bytecode VM?"; seriously?

I have tried contacting the owner, the response is pending.

I have tried hacking Bison into this behaviour, its too noisy.

I firmly believe code generation is the way to go, not just here,
but for DSL-es in general.

This project will heavy depend on tree-sitter,
there is no sense pretending otherwise with decoupling.

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
