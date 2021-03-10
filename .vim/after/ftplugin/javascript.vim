nnoremap <buffer> <Leader>r
      \ :!node %<CR>

let b:undo_ftplugin .= '|nunmap <buffer> <Leader>r'

set shiftwidth=2             " Indent with two spaces
set softtabstop=2            " Insert two spaces with tab key
