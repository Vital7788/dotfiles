nnoremap <buffer> <Leader>r
      \ :!python3 %<CR>

let b:undo_ftplugin .= '| nunmap <buffer> <Leader>r'

let b:ale_python_flake8_options = '--config=$HOME/.config/flake8'
if has('nvim')
    let b:ale_linters_ignore = ['pyright', 'pylsp']
endif
