function! select_makeprg#SelectorPopupWindow(items, type)
    let l:menu = &filetype . '#' . a:type . '#' . toupper(&filetype[0]) . &filetype[1:] 
                \  . toupper(a:type[0]) . a:type[1:] . 'MenuHandler'
    call popup_menu(a:items, #{
            \ callback: l:menu,
            \ })
endfunction
