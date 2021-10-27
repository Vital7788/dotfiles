# this command appends the ~/.zsh/completions directory onto the shell's function lookup list
# names of completers should be prefixed with an underscore
fpath=(~/.zsh/completions $fpath)

# should be called before compinit
zmodload zsh/complist

# autoload compinit function and call it to initialize completion for the current session
autoload -Uz compinit; compinit


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
#setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
#setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.


# zstyle pattern for completion
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# set completers to use, in order
zstyle ':completion:*' completer _extensions _complete _approximate

# allow selection from menu
#zstyle ':completion:*' menu 'auto select'
zstyle ':completion:*' menu select

zstyle ':completion:*' file-sort modification

# autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true

# complete case insensitive + complete partial words
# partial completion before '.', '_' or '-' e.g. f.b -> foo.bar
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+l:|=* r:|=*' 'r:|[._-]=* r:|=*'

# limit to len/3 errors
zstyle ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'


zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
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

# load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/completions/git-completion.bash
# git-completion.zsh is a function file, not designed to be sourced
