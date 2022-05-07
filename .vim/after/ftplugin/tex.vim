set textwidth=80
"set formatoptions+=a
let b:undo_ftplugin .= '| set textwidth&'

compiler pdflatex

nnoremap <buffer> <Leader>r
      \ :!zathura %<.pdf<CR>
let b:undo_ftplugin .= '| nunmap <buffer> <Leader>r'
