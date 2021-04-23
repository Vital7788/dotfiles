" load guard
if exists('g:loaded_statusline')
    finish
endif
let g:loaded_statusline = 1

function ActiveStatus()
    let statusline=""
    " display all highlight groups with their color
    " :so $VIMRUNTIME/syntax/hitest.vim
    let statusline.="%#DiffAdd#%{(mode()==#'n')?'\ \ NORMAL\ ':''}"
    let statusline.="%#DiffChange#%{(mode()==#'i')?'\ \ INSERT\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()==#'v')?'\ \ VISUAL\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()==#'V')?'\ \ V-LINE\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()==#'')?'\ \ V-BLOCK\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()==#'s')?'\ \ SELECT\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()==#'S')?'\ \ S-LINE\ ':''}"
    let statusline.="%#DiffDelete#%{(mode()==#'')?'\ \ S-BLOCK\ ':''}"
    let statusline.="%#DiffText#%{(mode()==#'R')?'\ \ REPLACE\ ':''}"
    let statusline.="%#Visual#%{(mode()==#'c')?'\ \ COMMAND\ ':''}"
    let statusline.="%#Statusline#"                                 " colour
    let statusline.="\ \ %n\ "                                      " buffer number
    let statusline.="\ %f\ "                                        " file name
    let statusline.="%r%m"                                          " flags
    let statusline.="%{gutentags#statusline('[', ']')}"             " gutentags status
    let statusline.="%="                                            " right align
    let statusline.="\ %y"                                          " file type
    let statusline.="\ %{&fileencoding?&fileencoding:&encoding}"    " file encoding
    let statusline.="\[%{&fileformat}\]\ "                          " file format
    let statusline.="\ %l/%L"                                       " line X of Y [percent of file]
    let statusline.="\ %c\ "                                        " current column
    return statusline
endfunction

function InactiveStatus()
    let statusline=""
    let statusline.="\ \ "                                          " buffer number
    let statusline.="\ %n\ "                                        " buffer number
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
