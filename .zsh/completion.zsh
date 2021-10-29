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


zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
# colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# set order of descriptions
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# use ls colors for complist
zstyle ':completion:*:*:*:*:default' list-colors \
       ${(s.:.)LS_COLORS}


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


typeset -g -A key
key[Up]='^[[A'
key[Down]='^[[B'
key[Right]='^[[C'
key[Left]='^[[D'
key[Return]='^M'
key[LineFeed]='^J'
key[Tab]='^I'
key[ShiftTab]='^[[Z'
key[ControlSpace]='^@'
key[DeleteList]='^D'
key[ListChoices]='^[^D'
key[Undo]='^_'

#bindkey ' ' magic-space
#bindkey '^[ ' self-insert-unmeta
#bindkey "${key[Tab]}" complete-word
#bindkey "${key[ShiftTab]}" list-more
#bindkey "${key[ControlSpace]}" expand-or-fuzzy-find

#bindkey "${key[Up]}" up-line-or-fuzzy-history
#bindkey "^[${key[Up]}" fzf-history-widget
#bindkey "${key[Down]}" down-line-or-menu-select
#bindkey "^[${key[Down]}" menu-select

# Completion menu behavior
# bindkey -M menuselect " " accept-line
#bindkey -M menuselect "${key[Tab]}" accept-and-hold
#bindkey -M menuselect -s "${key[Return]}" "${key[LineFeed]}${key[ListChoices]}"
#bindkey -M menuselect -s "${key[ShiftTab]}" "${key[DeleteList]}${key[Undo]}${key[ShiftTab]}"
#bindkey -M menuselect -s "${key[ControlSpace]}" "${key[LineFeed]}${key[ControlSpace]}"

# Wrap existing widgets to provide auto-completion.
#local widget
#for widget in self-insert delete-char backward-delete-char kill-word backward-kill-word
#do
#  eval "zle -N $widget
#  $widget() {
#    zle .$widget
#    zle list-choices
#  }"
#done

#zle -N magic-space
#magic-space() {
#  zle correct-word
#  zle .magic-space
#  zle list-choices
#}
#
#zle -N complete-word
#complete-word() {
#  local buffer=$BUFFER
#  zle _complete_word
#  if [[ $buffer != $BUFFER ]]
#  then
#    zle .auto-suffix-retain
#    zle list-choices
#  fi
#}
#
#zle -C _complete_word complete-word _complete_word
#_complete_word() {
#  local curcontext=$( _context complete-word )
#  _keep_old_list
#  _main_complete $@
#  _force_list
#}
#
#zle -C menu-select menu-select _menu_select
#_menu_select() {
#  local curcontext=$( _context menu-select )
#  _keep_old_list
#  _main_complete $@
#  _force_list
#}
#
#_keep_old_list() {
#  if [[ -v compstate[old_list] ]]
#  then
#    compstate[old_list]=keep
#  fi
#}
#
#_force_list() {
#  if (( ${#compstate[old_list]} == 0 ))
#  then
#    compstate[insert]=''
#    compstate[list]='list force'
#  fi
#}
#
#zle -C correct-word complete-word _correct_word
#_correct_word() {
#  local current_word=$SUFFIX$PREFIX
#  if (( CURRENT > 1 || ${#words[1]} > 0 || ${#current_word} > 0 ))
#  then
#    local curcontext=$( _context correct-word )
#    _main_complete $@
#  fi
#}
#
#zle -C list-choices list-choices _list_choices
#_list_choices() {
#  if (( PENDING == 0 && KEYS_QUEUED_COUNT == 0 ))
#  then
#    local current_word=$SUFFIX$PREFIX
#    if (( CURRENT > 1 || ${#words[1]} > 0 || ${#current_word} > 0 ))
#    then
#      local curcontext=$( _context list-choices )
#      _main_complete $@
#      if (( (compstate[list_lines] + BUFFERLINES + 1) > LINES
#         || ( compstate[list_max] != 0 && compstate[nmatches] > compstate[list_max] ) ))
#      then
#        compstate[list]=
#      fi
#    fi
#    if (( ${#compstate[list]} == 0 ))
#    then
#      zle -M ''
#    fi
#    # zle -M "$CURRENT ${#words[1]} ${#current_word} ${compstate[list_lines]} ${compstate[nmatches]}"
#  fi
#}
#
#zle -C list-more list-choices list_more
#list_more() {
#  local curcontext=$( _context list-more )
#  _main_complete $@
#}
#
#_context() {
#  local curcontext="${curcontext:-}"
#  if [[ -z "$curcontext" ]]; then
#    curcontext="$1:::"
#  else
#    curcontext="$1:${curcontext#*:}"
#  fi
#  echo $curcontext
#}
