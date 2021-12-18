set textwidth=80
"set formatoptions+=a

compiler pdflatex

nnoremap <buffer> <Leader>r
      \ :!zathura %<.pdf<CR>
let b:undo_ftplugin .= '|nunmap <buffer> <Leader>r'
