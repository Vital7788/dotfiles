function! GithubProjectGx() abort
  let l:line = getline('.')
  let l:match = matchlist(l:line, "\\v['\"]([[:alnum:]][-[:alnum:]]+)\\/([-[:alnum:].]+)['\"]")

  if len(l:match) > 0
    let l:url = printf('https://www.github.com/%s/%s', l:match[1], l:match[2])
    call netrw#BrowseX(l:url, 0)
  else
    call netrw#BrowseX(expand(get(g:, 'netrw_gx', '<cfile>')), netrw#CheckIfRemote())
  endif
endfunction

augroup GithubProjectGx
  autocmd!
  autocmd BufRead,BufNewFile *.lua nnoremap <buffer> <silent> gx :call GithubProjectGx()<cr>
augroup END
