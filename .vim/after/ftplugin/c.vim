set path+=/usr/include
let b:undo_ftplugin .= '| set path-=/usr/include'

compiler gcc

nnoremap <buffer> <Leader>r
      \ :!./%<.out<CR>

"let g:termdebug_popup = 0
"let b:undo_ftplugin .= '| unlet g:termdebug_popup'
"packadd termdebug
