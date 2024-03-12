if stridx(expand('%:p'), '/.config/nvim/') != -1
    setlocal keywordprg=:help
    let b:undo_ftplugin .= '| setlocal keywordprg<'
endif
