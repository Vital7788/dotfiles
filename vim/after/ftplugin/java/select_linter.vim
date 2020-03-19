" don't load if already loaded
if exists('b:loaded_ftp_java_select_linter')
    finish
endif

" flag as loaded
let b:loaded_ftp_java_select_linter = 1
let b:undo_ftplugin = b:undo_ftplugin
      \ . '|unlet b:loaded_ftp_java_select_linter'

" select linter
nnoremap <buffer> <silent> <Plug>(JavaLinterSelect)
      \ :<C-U>call java#linter#JavaLinterSelect()<CR>
let b:undo_ftplugin = b:undo_ftplugin
      \ . '|nunmap <buffer> <Plug>(JavaLinterSelect)'
      \ . '|nunmap <buffer> <Plug>(JavaLinterSelect)'
