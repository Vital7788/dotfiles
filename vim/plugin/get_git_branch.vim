
function GetGitBranch()
    return system(" pushd ".expand('%:p:h')." > /dev/null "
    \ . " && git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n' "
    \ . " && popd > /dev/null ")
endfunction

if g:os == "Linux"
    autocmd BufReadPost * let b:git_branch=GetGitBranch()
else
    let b:git_branch=""
endif
