path+=("${HOME}/.local/bin")
export PATH


export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

# dotfiles
export USERXSESSION="${XDG_CACHE_HOME}/X11/xsession"
export USERXSESSIONRC="${XDG_CACHE_HOME}/X11/xsessionrc"
export ALTUSERXSESSION="${XDG_CACHE_HOME}/X11/Xsession"
export ERRFILE="${XDG_CACHE_HOME}/X11/xsession-errors"

export NODE_REPL_HISTORY="${XDG_DATA_HOME}/node_repl_history"
export IPYTHONDIR="${XDG_CONFIG_HOME}/jupyter"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"
export ICEAUTHORITY="${XDG_CACHE_HOME}/ICEauthority"
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java"
export STACK_ROOT="${XDG_DATA_HOME}/stack"
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
export SSB_HOME="${XDG_DATA_HOME}/zoom"
