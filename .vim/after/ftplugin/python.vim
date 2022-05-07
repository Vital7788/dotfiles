nnoremap <buffer> <Leader>r
      \ :!python3 %<CR>

let b:undo_ftplugin .= '| nunmap <buffer> <Leader>r'

let g:ale_python_flake8_options = '--config=$HOME/.config/flake8'
let b:undo_ftplugin .= '| unlet g:ale_python_flake8_option'
