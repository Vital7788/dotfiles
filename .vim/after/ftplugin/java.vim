" default makeprg=javac -XLint
compiler javac_XLint

" Choose correct option when in school folder
if stridx(expand('%:p'), 'ad1') != -1
    call java#compiler#JavaCompilerMenuHandler('', 1)
elseif stridx(expand('%:p'), 'prog2') != -1
    call java#compiler#JavaCompilerMenuHandler('', 2)
endif

" mapping to run program
nnoremap <buffer> <expr> <Leader>r
      \ ':!java ' . b:classpath . b:modulepath . b:files . '<CR>'
let b:undo_ftplugin .= '|nunmap <buffer> <Leader>r'

" mapping to choose linter as makeprg
nmap <buffer> ,l
      \ <Plug>(JavaLinterSelect)
" mapping to choose compiler as makeprg
nmap <buffer> ,c
      \ <Plug>(JavaCompilerSelect)
let b:undo_ftplugin .= '|setlocal makeprg< errorformat<'
      \ . '|nunmap <buffer> ,l'
      \ . '|nunmap <buffer> ,c'

" mapping to copy non .java files to out/ directory
nnoremap <buffer> <Leader>c
      \ :call <SID>Copy()<CR>
let b:undo_ftplugin .= '|nunmap <buffer> <Leader>c'

function! s:Copy()
    call system("for file in $(find src -type f -not -name '*.java'); do cp $file $(echo $file | sed 's#^src#out#'); done")
    echo "copied files"
endfunction
