" handle linter selection
function! java#linter#JavaLinterMenuHandler(id, result)

    " XLint
    if a:result == 1
        compiler javac_XLint

    " PMD
    elseif a:result == 2
        compiler pmd
    endif

endfunction

" Interface function
function! java#linter#JavaLinterSelect() abort
    call select_makeprg#SelectorPopupWindow(['XLint', 'PMD'], 'linter')
endfunction
