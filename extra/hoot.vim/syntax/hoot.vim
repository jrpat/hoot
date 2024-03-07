syn region hootCode start=/\$\[[^!]/ end=/\]/ skip=/\\\]/ containedin=ALL
syn region hootComment start=/\$\[\!/ end=/\]/ skip=/\\\]/ containedin=ALL

syn region hootExpr start=/\$(/ end=/)/ skip=/\\)/ containedin=ALL
syn region hootExpr start=/[^$](/ end=/)/ skip=/\\)/ contained containedin=hootExpr

syn match hootVar /\v\$[[:alnum:]:]+/ containedin=ALL
syn match hootVar /\v\$\{[^}]+\}/ containedin=ALL

syn region hootTcl start=/[^$]\[/ end=/\]/ skip=/\\\]/ contained containedin=hootCode
syn region hootComment start="^\s*\#" skip="\\$" end="$" contained containedin=hootCode
syn region hootComment start=/;\s*\#/hs=s+1 skip="\\$" end="$" contained containedin=hootCode

hi def link hootComment Comment
hi def link hootVar Identifier
hi def link hootExpr Identifier
hi def link hootCode Macro
hi def link hootTcl Macro

