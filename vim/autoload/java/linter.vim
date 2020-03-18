function! java#linter#JavaLinterMenuHandler(id, result)
    if a:result == 1
        compiler javac_XLint
    elseif a:result == 2
        compiler pmd
    endif
endfunction

" Interface function
function! java#linter#JavaLinterSelect() abort
    call select_makeprg#SelectorPopupWindow(['XLint', 'PMD'], 'linter')
endfunction
