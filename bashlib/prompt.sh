########################################################
# Set the bash prompt
#
#  Syntax for style(X) & color(YY): \[e[X;YYm\]
#
#    Style(X) can be: 
#      0   :  Plain
#      1   :  Bold
#
#    Color(YY) can be:
#      31  :  Red
#      32  :  Green
#      33  :  Yellow
#      34  :  Dark Blue
#      35  :  Purple
#      36  :  Light blue
#      37  :  White
#
#    Plain/Reset: \[\e[0m\]
#


### Helpers
#  This is to reuse the smiley return code indicator in any of the patterns below
smileyCommand="if [ \$? = 0 ]; then echo -e '\e[01;32m:)'; else echo -e '\e[01;31m:('; fi"

# This will display in the terminal title bar, but not in prompt
titleBar="\[\033]0;\u@\h:\w\007\]"


###
# Fancy Prompt
#
# This prompt pattern looks like:
#
# ┌─[ user @ host ]-[ /path/to/stuff ]─[ 04:59:59 ]
# └─[ $ ]› 
#
function prompt_fancy {
    # Define colors to prompt components
    local cPlain="\[\e[0m\]"
    local cLines="\[\e[0;36m\]"
    local cAtSign="\[\e[1;36m\]"
    local cUser="\[\e[1;33m\]"
    local cHost="\[\e[1;33m\]"
    local cPath="\[\e[1;34m\]"
    local cTime="\[\e[0;31m\]" 
    local cPrompt="\[\e[1;37m\]"

    export PS1="\n\
${cLines}┌─[ ${cUser}\u${cAtSign} @ ${cHost}\h${cLines} ]-[ ${cPath}\w${cLines} ]─[ ${cTime}\t${cLines} ]\n\
${cLines}└─[ \`$smileyCommand\` ${cLines}]› ${titleBar}\[\e[0m\]"
}

###
# Red Line Prompt
#
# This prompt pattern looks like (where line takes up 100% screen width)
#
# ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# ) 
#
function prompt_redline {
    export PS1="\e]2;\$(pwd)\a\e]1;\$(pwd)\a\e[31;1m\$(s=\$(printf "%*s" \$COLUMNS); echo \${s// /―})\n)\e[0m ";
}

###
# Smiley Prompt
#
# Color-coded Smiley pattern depends on exit status of previous command:
#   After success:  :)
#   After fail:     :(
#
function prompt_smiley {
    export PS1="\[\e[01;32m\]\u@\h \[\e[01;34m\]\W \`$smileyCommand\` \[\e[01;34m\]$\[\e[00m\] "
}


###
# Set Prompt
#  Use this to pass in the key of which prompt to use
function set_prompt {
    default="fancy"
    if [[ $1 ]]; then
        patternFunction="prompt_$1"
    else
        patternFunction="prompt_$default"
    fi
    $patternFunction 
}

