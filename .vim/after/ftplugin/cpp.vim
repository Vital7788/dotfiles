set path+=/usr/include
let b:undo_ftplugin .= '| set path-=/usr/include'

compiler gpp

"if !empty(findfile("CMakeLists.txt", ".;"))
"    let b:buildpath=expand('%:p')[:stridx(expand('%:p'), '/src/')] . 'build/'
"    compiler cmake
"    nnoremap <buffer> <expr> <Leader>r
"          \ ':!' . globpath(b:buildpath, '*.out') . '<CR>'
"endif

nnoremap <buffer> <Leader>r
      \ :!./%<.out<CR>
