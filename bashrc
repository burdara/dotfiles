
### Path
PATH=/usr/local/bin:$PATH
PATH=$PATH:/usr/local/heroku/bin
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin
PATH=$PATH:/usr/local/git/bin
PATH=$PATH:$HOME/.rvm/bin
export PATH=$PATH

### Environment Variables
export GRADLE_OPTS="-Xmx1g"
export JAVA_HOME=/Library/Java/Home
export CATALINA_HOME=/Library/Tomcat/Home

# For SSH
export SHCN="StrictHostKeyChecking=no"

### Aliases
# ls
alias ll='ls -l'
alias l='ls -l'
alias la='ls -la'

# git
alias ga='git add'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gundo="git reset HEAD"
# Disk usage by Folder
alias duf='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'

