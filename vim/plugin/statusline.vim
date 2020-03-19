" load guard
if exists('g:loaded_statusline')
    finish
endif
let g:loaded_statusline = 1

" get git branch
function StatuslineGit()
    let l:git_branch = exists("b:git_branch") ? b:git_branch : ''
    return strlen(l:git_branch) > 0 ? '  '.l:git_branch.' ' : ''
endfunction

function ActiveStatus()
    let statusline=""
    " display all highlight groups with their color
    " :so $VIMRUNTIME/syntax/hitest.vim
    let statusline.="%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}"
    let statusline.="%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()=='v')?'\ \ VISUAL\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()=='vl')?'\ \ V-LINE\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()=='')?'\ \ V-BLOCK\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()=='s')?'\ \ SELECT\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()=='sl')?'\ \ S-LINE\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()=='')?'\ \ S-BLOCK\ ':''}"
    let statusline.="%#DiffText#%{(mode()=='r')?'\ \ REPLACE\ ':''}"
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

autocmd WinEnter * setlocal statusline=%!ActiveStatus()
autocmd WinLeave * setlocal statusline=%!InactiveStatus()

set statusline=%!ActiveStatus()
