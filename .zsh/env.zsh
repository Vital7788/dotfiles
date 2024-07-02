path+=("${HOME}/.local/bin")
export PATH

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/cuda/extras/CUPTI/lib64"

# export TERM=wezterm

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
export CUDA_CACHE_PATH="${XDG_CACHE_HOME}/nv"
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"
export GTK2_RC_FILES="${XDG_CONFIG_HOME}/gtk-2.0"
export KDEHOME="${XDG_CONFIG_HOME}/kde4"
export PSQL_HISTORY="${XDG_STATE_HOME}/psql_history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npmrc"
export ANDROID_HOME="${XDG_DATA_HOME}/android"
export MAXIMA_USERDIR="${XDG_CONFIG_HOME}/maxima"
export DOT_SAGE="${XDG_CONFIG_HOME}/sage"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export TEXMFVAR="${XDG_CACHE_HOME}/texlive/texmf-var"
export W3M_DIR="${XDG_DATA_HOME}/w3m"
