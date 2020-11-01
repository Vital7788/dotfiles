" don't load if already loaded
if exists('b:loaded_ftp_java_select_compiler')
    finish
endif

" flag as loaded
let b:loaded_ftp_java_select_compiler = 1
let b:undo_ftplugin = b:undo_ftplugin
      \ . '|unlet b:loaded_ftp_java_select_compiler'

" select compiler
nnoremap <buffer> <silent> <Plug>(JavaCompilerSelect)
      \ :<C-U>call java#compiler#JavaCompilerSelect()<CR>
let b:undo_ftplugin = b:undo_ftplugin
      \ . '|nunmap <buffer> <Plug>(JavaCompilerSelect)'
      \ . '|nunmap <buffer> <Plug>(JavaCompilerSelect)'
