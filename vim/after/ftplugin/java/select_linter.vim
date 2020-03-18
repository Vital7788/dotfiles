if exists('b:loaded_ftp_java_select_linter')
    finish
endif

let b:loaded_ftp_java_select_linter = 1
let b:undo_ftplugin = b:undo_ftplugin
      \ . '|unlet b:loaded_ftp_java_select_linter'

nnoremap <buffer> <silent> <Plug>(JavaLinterSelect)
      \ :<C-U>call java#linter#JavaLinterSelect()<CR>

let b:undo_ftplugin = b:undo_ftplugin
      \ . '|nunmap <buffer> <Plug>(JavaLinterSelect)'
      \ . '|nunmap <buffer> <Plug>(JavaLinterSelect)'
