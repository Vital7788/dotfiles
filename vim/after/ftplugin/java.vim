compiler javac_XLint

nnoremap <buffer> <Leader>r
      \ :!java -cp .:/opt/hamcrest-2.2.jar:/opt/junit-4.13.jar org.junit.runner.JUnitCore SimpleTest<CR>

nnoremap <buffer> ,c
      \ :<C-U>compiler java<CR>

nnoremap <buffer> ,x
      \ :<C-U>compiler javac_XLint<CR>

let b:undo_ftplugin .= '|setlocal makeprg< errorformat<'
      \ . '|nunmap <buffer> <Leader>r'
      \ . '|nunmap <buffer> ,c'
      \ . '|nunmap <buffer> ,x'
