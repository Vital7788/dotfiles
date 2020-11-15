"set path+=/usr/include

let g:ale_c_clangd_options="-I" . getcwd()

let g:termdebug_popup = 0
packadd termdebug
