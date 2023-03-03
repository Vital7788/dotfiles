set path+=/usr/include
let b:undo_ftplugin .= '| set path-=/usr/include'

compiler gcc

nnoremap <buffer> <Leader>r
      \ :!./%<.out<CR>

let b:undo_ftplugin .= '| nunmap <buffer> <Leader>r'

let b:ale_c_clangd_options="-I" . getcwd()

let b:ale_linters = ['clangcheck', 'clangd', 'clangtidy', 'cppcheck', 'cpplint']

if has('nvim')
    let b:ale_linters_ignore = ['clangd']
endif


"let g:termdebug_popup = 0
"let b:undo_ftplugin .= '| unlet g:termdebug_popup'
"packadd termdebug
