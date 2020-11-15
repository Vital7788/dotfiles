" mapping to run program
nnoremap <buffer> <expr> <Leader>r
      \ ':!java ' . b:classpath . b:modulepath . b:files . '<CR>'
let b:undo_ftplugin .= '|nunmap <buffer> <Leader>r'

" mapping to copy non .java files to out/ directory
nnoremap <buffer> <Leader>c
      \ :call <SID>Copy()<CR>
let b:undo_ftplugin .= '|nunmap <buffer> <Leader>c'

function! s:Copy()
    call system("for file in $(find src -type f -not -name '*.java'); do cp $file $(echo $file | sed 's#^src#out#'); done")
    echo "copied files"
endfunction
