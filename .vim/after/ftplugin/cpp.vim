compiler cpp
nnoremap <buffer> <Leader>r
      \ :!./%<.out<CR>

"if !empty(findfile("CMakeLists.txt", ".;"))
"    let b:buildpath=expand('%:p')[:stridx(expand('%:p'), '/src/')] . 'build/'
"    compiler cmake
"    nnoremap <buffer> <expr> <Leader>r
"          \ ':!' . globpath(b:buildpath, '*.out') . '<CR>'
"endif

let b:undo_ftplugin .= '|nunmap <buffer> <Leader>r'

"set path+=/usr/include

let g:ale_cpp_clangd_options="-I" . getcwd()

let g:termdebug_popup = 0
packadd termdebug
