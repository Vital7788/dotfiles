setlocal textwidth=80
setlocal formatoptions+=aw
if !exists("b:undo_ftplugin")
    let b:undo_ftplugin = 'setlocal textwidth< formatoptions<'
else
    let b:undo_ftplugin .= ' | setlocal textwidth< formatoptions<'
endif

let b:ale_linters_ignore = ['lacheck']

" compiler pdflatex

"nnoremap <buffer> <Leader>r
"      \ :!zathura %<.pdf<CR>
"let b:undo_ftplugin .= '| nunmap <buffer> <Leader>r'
