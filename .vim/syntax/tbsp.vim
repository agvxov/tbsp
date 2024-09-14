runtime! syntax/c.vim
unlet b:current_syntax

syn keyword tbspDirection       enter leave
syn match tbspTop               "%top"
syn match tbspLanaguage         "%language"
syn match tbspSeparator         "%%"

hi link tbspDirection   Type
hi link tbspTop         Statement
hi link tbspLanaguage   Statement
hi link tbspSeparator   Todo

syn include syntax/c.vim

let b:current = "tbsp"
