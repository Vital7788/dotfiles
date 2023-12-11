" map tab to autocomplete or tab depending on context

function CleverTab()
    let l:line = strpart( getline('.'), 0, col('.')-1)
    let l:lastchar = matchstr(getline('.'), '.\%' . col('.') . 'c')
    " if popup menu is visible, go to next in the list
    if pumvisible()
        return "\<C-n>"
    " if the last character is a space, indent
    elseif l:lastchar =~ '\s' || l:line =~ '^$'
        return "\<Tab>"
    " if the last character is a slash, call file-completion
    elseif l:lastchar =~ "/"
        return "\<C-x>\<C-f>"
    " call omni completion if has omnifunc
    elseif len(&omnifunc) > 0
        return "\<C-x>\<C-o>"
    " call word completion otherwise
    else
        return "\<C-n>"
    endif
endfunction

inoremap <expr> <silent> <Tab> CleverTab()
