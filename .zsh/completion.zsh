# should be called before compinit
zmodload zsh/complist

# autoload compinit function and call it to initialize completion for the current session
autoload -Uz compinit; compinit -d .zsh/zcompdump

# Use hjlk in menu selection (during completion)
# Doesn't work well with interactive mode
#bindkey -M menuselect 'h' vi-backward-char
#bindkey -M menuselect 'k' vi-up-line-or-history
#bindkey -M menuselect 'j' vi-down-line-or-history
#bindkey -M menuselect 'l' vi-forward-char

#bindkey -M menuselect '^[' vi-insert                      # Insert
#bindkey -M menuselect '^i' accept-and-infer-next-history  # Next
#bindkey -M menuselect '^u' undo                           # Undo


_comp_options+=(globdots) # with hidden files
setopt GLOB_COMPLETE      # Show autocompletion menu with globs
# setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.


# zstyle pattern for completion
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# set completers to use, in order
zstyle ':completion:*' completer _extensions _complete _approximate

# allow selection from menu
#zstyle ':completion:*' menu 'auto select'
zstyle ':completion:*' menu select

zstyle ':completion:*' file-sort modification

# add .. as possible completion when current prefix is '' or '.'
# or consists only of a path beginning with '../'
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'

# autocomplete options for cd instead of directory stack
#zstyle ':completion:*' complete-options true

# complete case insensitive + complete partial words
# partial completion before '.', '_' or '-' e.g. f.b -> foo.bar
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+l:|=* r:|=*' 'r:|[._-]=* r:|=*'

# limit to len/3 errors
zstyle ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# set order of descriptions
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# only display some tags for the command cd
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
# never select parent directory with cd
zstyle ':completion:*:*:cd:*' ignore-parents parent pwd

# ignore certain extensions for vim
zstyle ':completion:*:*:vim:*' file-patterns '^*.(class|pdf):source-files' '*:all-files'

# allow completion with option stacking
# e.g. docker run -it <TAB>
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# patch git switch completion to only complete local branches
# https://unix.stackexchange.com/a/450133
# _git 2>/dev/null
# current="_alternative 'branches::__git_branch_names' 'remote-branch-names-noprefix::__git_remote_branch_names_noprefix' && ret=0"
# replacement="__git_branch_names && ret=0"
# functions[_git-switch]=${functions[_git-switch]/$current/$replacement}

if [ ! -f ~/.zsh/fzf-tab/fzf-tab.plugin.zsh ]; then
    zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
    zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
    zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
    zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
    zstyle ':completion:*:default' list-prompt '%S%M matches%s'

    # only complete local files for performance
    # https://superuser.com/a/459057
    __git_files () {
        _wanted files expl 'local files' _files
    }
else
    source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh
    FZF_GIT_DEFAULT_FLAGS=("--height=50%"
        "--layout=reverse" "--multi" "--min-height=20+" "--border"
        "--no-separator" "--header-border=horizontal"
        "--preview-window=right,50%" "--preview-border=line"
        "--bind=ctrl-/:change-preview-window(down,50%|hidden|)"
    )

    GIT_PREVIEW_FILE='git -c core.quotePath=false diff --no-ext-diff --color=always -- $realpath | delta; bat --style=full --color=always --pager=never $realpath'
    GIT_PREVIEW_HASH='git show --color=always --decorate $word | delta'
    GIT_PREVIEW_BRANCH="git log --oneline --graph --date=short --color=always --pretty='format:%C(auto)%cd %h%d %s' \$word"

    # set descriptions format to enable group support
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':fzf-tab:*' fzf-flags --height=40%
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    zstyle ':fzf-tab:*' switch-group '<' '>'
    zstyle ':fzf-tab:*' prefix ''
    zstyle ':fzf-tab:*' single-group header

    zstyle ':fzf-tab:complete:git-*:*' fzf-flags "${FZF_GIT_DEFAULT_FLAGS[@]}"
    zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
            'git help $word | bat -plman --color=always'
    zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview "$GIT_PREVIEW_FILE"
    zstyle ':fzf-tab:complete:git-show:*' fzf-flags "${FZF_GIT_DEFAULT_FLAGS[@]}"
    zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
        "case \$group in
        '[cached file]')
            $GIT_PREVIEW_FILE
            ;;
        *)
            $GIT_PREVIEW_HASH
            ;;
        esac"

    zstyle ':fzf-tab:complete:git-(log|switch|branch):*' fzf-preview "$GIT_PREVIEW_BRANCH"
    zstyle ':fzf-tab:complete:git-switch:*' fzf-flags \
        "${FZF_GIT_DEFAULT_FLAGS[@]}" \
        --tiebreak begin \
        --preview-window down,border-top,40% \
        --color hl:underline,hl+:underline \
        --no-hscroll
fi
