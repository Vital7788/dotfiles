" auto turn off highlighting
" https://github.com/romainl/vim-cool/issues/9

function HlSearch()
    let s:pos = match(getline('.'), @/, col('.') - 1) + 1
    if s:pos != col('.')
        call StopHL()
    endif
endfunction

function StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        sil call feedkeys("\<Plug>(StopHL)", 'm')
    endif
endfunction

noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
