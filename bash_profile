###
#  Bash Profile
#
#  Uses custom functions defined in ~/.bashlib/
###
if [[ ! $PROFILE_LOADED ]]; then 
    printf "Loading Bash Profile..."
    
    ### Include libs
    scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    if [[ -d $scriptPath/.bashlib ]]; then 
        source $scriptPath/.bashlib/prompt.sh
    else
        echo -e "\n\n\tError:  missing ~/.bashlib/ dir!!!\n\n";
    fi
    
    
    ### Aliases
    alias ll='ls -l'
    alias l='ls -l'
    alias sshhh='ssh -i /code/mpa/trunk/mpa-tools/ec2/keys/pocadmins.pem'
    
    
    ### Shell Settings
    set -o vi                                # Set vi mode for bash shell
    export CLICOLOR=1                        # Turn on colors
    export LSCOLORS=gxfxcxdxbxegedabagacad   # Color files by type
    
    
    ### Prompt
    # Pass prompt pattern key - see bashlibs/prompt.sh
    # (smiley|redline|fancy)
    set_prompt fancy  
    
    
    ### Path
    PATH=$PATH:$HOME/.rvm/bin 
    export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin:$PATH
    
    
    ### Environment Variables
    export GRADLE_OPTS="-Xmx1g"
    export JAVA_HOME=/Library/Java/Home
    export CATALINA_HOME=/Library/Tomcat/Home
    
    
    ### Misc
    # Ruby Version Mmanager
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
    
    # Keep this in to only load once
    export PROFILE_LOADED="yes" 
    printf "Done.\n"
fi
