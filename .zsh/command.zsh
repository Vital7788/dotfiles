# https://stackoverflow.com/a/24967501
#
# SYNOPSIS
#   manopt command opt
#
# DESCRIPTION
#   Returns the portion of COMMAND's man page describing option OPT.
#   Note: Result is plain text - formatting is lost.
#
#   OPT may be a short option (e.g., -F) or long option (e.g., --fixed-strings);
#   specifying the preceding '-' or '--' is OPTIONAL - UNLESS with long option
#   names preceded only by *1* '-', such as the actions for the `find` command.
#
#   Matching is exact by default; to turn on prefix matching for long options,
#   quote the prefix and append '.*', e.g.: `manopt find '-exec.*'` finds
#   both '-exec' and 'execdir'.
#
# EXAMPLES
#   manopt ls l           # same as: manopt ls -l
#   manopt sort reverse   # same as: manopt sort --reverse
#   manopt find -print    # MUST prefix with '-' here.
#   manopt find '-exec.*' # find options *starting* with '-exec'
manopt() {
    local cmd=$1 opt=$2
    [[ $opt == -* ]] || { (( ${#opt} == 1 )) && opt="-$opt" || opt="--$opt"; }
    man "$cmd" | col -b | awk -v opt="$opt" -v RS= '$0 ~ "(^|,)[[:blank:]]+" opt "([[:punct:][:space:]]|$)"'
}

# Clean up patch file
scrub_patch() {
    sed -i \
        -e '/^index /d' \
        -e '/^new file mode /d' \
        -e '/^Index:/d' \
        -e '/^=========/d' \
        -e '/^RCS file:/d' \
        -e '/^retrieving/d' \
        -e '/^diff/d' \
        -e '/^Files .* differ$/d' \
        -e '/^Only in /d' \
        -e '/^Common subdirectories/d' \
        -e '/^deleted file mode [0-9]*$/d' \
        -e '/^+++/s:\t.*::' \
        -e '/^---/s:\t.*::' \
        "$@"
}

open() {
    local file=$1

    if [[ $# -lt 1 ]]
    then
        file=$(fzf)
        if [[ $file ]]
        then
            xdg-open $file & disown && exit
        fi
        return
    fi

    if [[ -d $file ]]
    then
        file=$(fzf --walker-root=$file)
        if [[ $file ]]
        then
            xdg-open $file & disown && exit
        fi
    elif [[ -f $file ]]
    then
        xdg-open $file & disown && exit
    else
        echo "$file is not a valid file or directory"
    fi
}
