syn region hootCode start=/\$\[/ end=/\]/ skip=/\\\]/ containedin=hootCode

syn match hootVar /\v\$\{?\k+\}?/ containedin=hootCode
syn region hootTcl start=/[^$]\[/ end=/\]/ skip=/\\\]/ contained containedin=hootCode
syn region  hootComment start="^\s*\#" skip="\\$" end="$" contained containedin=hootCode
syn region  hootComment	start=/;\s*\#/hs=s+1 skip="\\$" end="$" contained containedin=hootCode

hi def link hootComment Comment
hi def link hootVar Identifier
hi def link hootCode PreProc
hi def link hootTcl PreProc

