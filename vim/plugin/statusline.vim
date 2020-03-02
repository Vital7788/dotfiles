" get git branch
function! StatuslineGit()
    let l:git_branch = exists("b:git_branch") ? b:git_branch : ''
    return strlen(l:git_branch) > 0 ? '  '.l:git_branch.' ' : ''
endfunction

" get mode
" :help mode()
let currentmode={
    \ 'n'      : 'n',
    \ 'no'     : 'no',
    \ 'v'      : 'v',
    \ 'V'      : 'vl',
    \ ''     : 'vb',
    \ 's'      : 's',
    \ 'S'      : 'sl',
    \ ''     : 'sb',
    \ 'i'      : 'i',
    \ 'ic'     : 'ic',
    \ 'ix'     : 'ix',
    \ 'R'      : 'r',
    \ 'Rc'     : 'rc',
    \ 'Rv'     : 'rv',
    \ 'Rx'     : 'rx',
    \ 'c'      : 'c',
    \ 'cv'     : 'cv',
    \ 'ce'     : 'ce',
    \ 'r'      : 'r',
    \ 'rm'     : 'rm',
    \ 'r?'     : 'r?',
    \ '!'      : '!',
    \ 't'      : 't',
    \}

function ActiveStatus()
    let statusline=""
    " display all highlight groups with their color
    " :so $VIMRUNTIME/syntax/hitest.vim
    let statusline.="%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}"
    let statusline.="%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}"
    let statusline.="%#DiffDelete#%{(currentmode[mode()]=='v')?'\ \ VISUAL\ ':''}"
    let statusline.="%#DiffDelete#%{(currentmode[mode()]=='vl')?'\ \ V-LINE\ ':''}"
    let statusline.="%#DiffDelete#%{(currentmode[mode()]=='vb')?'\ \ V-BLOCK\ ':''}"
    let statusline.="%#DiffDelete#%{(currentmode[mode()]=='s')?'\ \ SELECT\ ':''}"
    let statusline.="%#DiffDelete#%{(currentmode[mode()]=='sl')?'\ \ S-LINE\ ':''}"
    let statusline.="%#DiffDelete#%{(currentmode[mode()]=='sb')?'\ \ S-BLOCK\ ':''}"
    let statusline.="%#DiffText#%{(currentmode[mode()]=='r')?'\ \ REPLACE\ ':''}"
    let statusline.="%#Visual#%{(mode()=='c')?'\ \ COMMAND\ ':''}"
    let statusline.="%#GruvboxBlueSign#"
    let statusline.="\ %n\ "                                        " buffer number
    let statusline.="%#GruvboxPurpleSign#"
    let statusline.="%{StatuslineGit()}"                            " git branch
    let statusline.="%#StatuslineNC#"                               " colour
    let statusline.="\ %f\ "                                        " file name
    let statusline.="%#GruvboxRedSign#"                             " colour
    let statusline.="%r%m"                                          " flags
    let statusline.="%="                                            " right align
    let statusline.="%#StatusLineNC#"                               " colour
    let statusline.="\ %y"                                          " file type
    let statusline.="\ %{&fileencoding?&fileencoding:&encoding}"    " file encoding
    let statusline.="\[%{&fileformat}\]\ "                          " file format
    let statusline.="%#GruvboxGreenSign#"                           " colour
    let statusline.="\ %l/%L"                                       " line X of Y [percent of file]
    let statusline.="%#GruvboxAquaSign#"                            " colour
    let statusline.="\ %c\ "                                        " current column
    return statusline
endfunction

function InactiveStatus()
    let statusline=""
    let statusline.="\ \ "                                          " buffer number
    let statusline.="%#GruvboxBlueSign#"
    let statusline.="\ %n\ "                                        " buffer number
    let statusline.="%{StatuslineGit()}"                            " git branch
    let statusline.="%#StatusLineNC#"
    let statusline.="\ %f\ "                                        " file name
    let statusline.="%r%m"                                          " flags
    let statusline.="%="                                            " right align
    let statusline.="\ %y"                                          " file type
    let statusline.="\ %{&fileencoding?&fileencoding:&encoding}"    " file encoding
    let statusline.="\[%{&fileformat}\]\ "                          " file format
    let statusline.="\ %l/%L"                                       " line X of Y [percent of file]
    let statusline.="\ %c\ "                                        " current column
    return statusline
endfunction

