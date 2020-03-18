if stridx(expand('%:p'), 'ad1') != -1
    call java#compiler#JavaCompilerMenuHandler('', 1)
elseif stridx(expand('%:p'), 'prog2') != -1
    call java#compiler#JavaCompilerMenuHandler('', 2)
endif

compiler javac_XLint

nnoremap <buffer> <expr> <Leader>r
      \ ':!java ' . b:classpath . b:modulepath . b:files . '<CR>'

nmap <buffer> ,l
      \ <Plug>(JavaLinterSelect)

nmap <buffer> ,c
      \ <Plug>(JavaCompilerSelect)

let b:undo_ftplugin .= '|setlocal makeprg< errorformat<'
      \ . '|nunmap <buffer> <Leader>r'
      \ . '|nunmap <buffer> ,l'
      \ . '|nunmap <buffer> ,c'
