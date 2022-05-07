" Don't complete certain files that I'm not likely to want to manipulate from
" within Vim; this is kind of expensive to reload, so I've made it a plugin
" with a load guard
if &compatible || v:version < 700 || !has('wildignore')
  finish
endif
if exists('g:loaded_wildmenu')
  finish
endif
let g:loaded_wildmenu = 1

" Helper function for local scope
function! s:Wildignore(wilder) abort

  " New empty array
  let l:ignores = []

  " Archives
  let l:ignores += [
        \ '*.7z'
        \,'*.bz2'
        \,'*.gz'
        \,'*.rar'
        \,'*.tar'
        \,'*.xz'
        \,'*.zip'
        \ ]

  " Bytecode
  let l:ignores += [
        \ '*.class'
        \,'*.pyc'
        \ ]

  " Databases
  let l:ignores += [
        \ '*.db'
        \,'*.dbm'
        \,'*.sdbm'
        \,'*.sqlite'
        \ ]

  " Disk
  let l:ignores += [
        \ '*.adf'
        \,'*.bin'
        \,'*.hdf'
        \,'*.iso'
        \ ]

  " Documents
  let l:ignores += [
        \ '*.docx'
        \,'*.djvu'
        \,'*.odp'
        \,'*.ods'
        \,'*.odt'
        \,'*.pdf'
        \,'*.ppt'
        \,'*.pptx'
        \,'*.xls'
        \,'*.xlsx'
        \ ]

  " Encrypted
  let l:ignores += [
        \ '*.asc'
        \,'*.gpg'
        \ ]

  " Executables
  let l:ignores += [
        \ '*.exe'
        \ ]

  " Fonts
  let l:ignores += [
        \ '*.ttf'
        \ ]

  " Incomplete
  let l:ignores += [
        \ '*.filepart'
        \ ]

  " Objects
  let l:ignores += [
        \ '*.a'
        \,'*.o'
        \ ]

  " Images
  let l:ignores += [
        \ '*.bmp'
        \,'*.gd2'
        \,'*.gif'
        \,'*.ico'
        \,'*.jpeg'
        \,'*.jpg'
        \,'*.pbm'
        \,'*.png'
        \,'*.psd'
        \,'*.tga'
        \,'*.xbm'
        \,'*.xcf'
        \,'*.xpm'
        \ ]

  " Sound
  let l:ignores += [
        \ '*.au'
        \,'*.aup'
        \,'*.flac'
        \,'*.mid'
        \,'*.m4a'
        \,'*.mp3'
        \,'*.ogg'
        \,'*.opus'
        \,'*.s3m'
        \,'*.wav'
        \ ]

  " Video
  let l:ignores += [
        \ '*.avi'
        \,'*.gifv'
        \,'*.mp4'
        \,'*.ogv'
        \,'*.rm'
        \,'*.swf'
        \,'*.webm'
        \,'*.mkv'
        \ ]

  " Version control
  let l:ignores += [
        \ '.git'
        \,'.hg'
        \,'.svn'
        \ ]

  " Vim
  let l:ignores += [
        \ '*~'
        \,'*.swp'
        \ ]

  " If on a system where case matters for filenames, for any that had
  " lowercase letters, add their uppercase analogues
  if has('fname_case')
    for l:ignore in l:ignores
      if l:ignore =~# '\l'
        call add(l:ignores, toupper(l:ignore))
      endif
    endfor
  endif

  if a:wilder
      " if using wilder, create a list of arguments to give to fd
      let l:args = []
      for elem in l:ignores
          let l:args += ['-E', elem]
      endfor
      return l:args
  else
    " Return the completed setting
    return join(l:ignores, ',')
  endif

endfunction

if !has('nvim')
    let &wildignore = s:Wildignore(0)
else
    " Set up wilder if using neovim
    call wilder#setup({
        \ 'modes': [':'],
        \ 'enable_cmdline_enter': 0,
        \ 'next_key': '<Tab>',
        \ 'previous_key': '<S-Tab>',
        \ 'accept_key': '<C-n>',
        \ 'reject_key': '<C-p>',
        \ })

    let s:fd_command = ['fd', '-tf'] + s:Wildignore(1)
    call wilder#set_option('pipeline', [
        \   wilder#branch(
        \     wilder#python_file_finder_pipeline({
        \       'file_command': {_, arg -> stridx(arg, '.') != -1 ? s:fd_command + ['-H'] : s:fd_command},
        \       'dir_command': ['fd', '-td'],
        \       'filters': ['cpsm_filter'],
        \       'path': wilder#project_root([]),
        \     }),
        \     wilder#cmdline_pipeline({
        \       'fuzzy': 2,
        \       'fuzzy_filter': has('nvim') ? wilder#lua_fzy_filter() : wilder#vim_fuzzy_filter(),
        \     }),
        \     [
        \       wilder#check({_, x -> empty(x)}),
        \       wilder#history(),
        \     ],
        \   ),
        \ ])

    let s:highlighters = [
        \ wilder#pcre2_highlighter(),
        \ has('nvim') ? wilder#lua_fzy_highlighter() : wilder#cpsm_highlighter(),
        \ ]

    call wilder#set_option('renderer',
        \ wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
        \     'max_height': 12,
        \     'max_width': '100%',
        \     'border': 'rounded',
        \     'empty_message': wilder#popupmenu_empty_message_with_spinner(),
        \     'highlighter': s:highlighters,
        \     'left': [
        \        ' ',
        \        wilder#popupmenu_buffer_flags({
        \          'flags': '1u% +- ',
        \          'icons': {'%': '', '#': '', '+': '', '=': '', '-': ''},
        \        }),
        \     ],
        \     'right': [
        \        ' ',
        \        wilder#popupmenu_scrollbar(),
        \     ],
        \ })))

    autocmd CmdlineEnter * let g:wilder_active = 0
    function! s:handle_space()
        if !g:wilder_active && index(['e', 'b', 'find', 'cd'], getcmdline()) != -1
            let g:wilder_active = 1
            call wilder#main#start()
        endif
        return "\<Space>"
    endfunction
    cnoremap <expr> <Space> wilder#in_context() ? <SID>handle_space() : "\<Space>"
endif
