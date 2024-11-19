nmap <buffer> { <Plug>(qf_previous_file)
nmap <buffer> } <Plug>(qf_next_file)

" Normal: `dd` removes item from the quickfix list.
" Visual: `d` removes all selected items, gk keeps all selected items
nnoremap <buffer> dd :.Reject<CR>
xnoremap <buffer> d :'<,'>Reject<CR>
nnoremap <buffer> gk :.Keep<CR>
xnoremap <buffer> gk :'<,'>Keep<CR>
