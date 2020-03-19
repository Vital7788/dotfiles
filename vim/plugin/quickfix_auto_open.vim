" Always pop open quickfix and location lists when changed
augroup quickfix_auto_open
  autocmd!
  autocmd QuickfixCmdPost [^l]* cwindow
  autocmd QuickfixCmdPost l* lwindow
  autocmd VimEnter * cwindow
augroup END
