nnoremap <buffer> ,r
      \ :!python3 %<CR>

let b:undo_ftplugin .= '|nunmap <buffer> ,r'
