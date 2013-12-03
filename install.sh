#!/usr/bin/env bash
#
# This script creates symbolic links from the
# home directory to files managed here.
#

### Variables
myself=$(whoami)
dotDir=$HOME/dotfiles          # dotfiles directory
bakDir=$HOME/dotfiles/backups  # dotfiles backup directory
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create list of files/folders to symlink in homedir
files="$(ls | grep -vE '(README.md|backups|install.sh|spf13-vim.sh|gitconfig|gitignore_global)')"

### Functions
confirmBackup() {
    echo -e "\nThis will create symlinks from home dir to $dotDir, and backup any existing home dir files to $bakDir:\n\n$files\n"
    read -p "Continue? (y/n) " -n 1 -r
    [[ "$REPLY" != "y" ]] && echo "Exiting." && exit 0
    echo "Let's do this!"
}
createBackupDir() {
    if [[ ! -d $bakDir ]]; then
        echo -e "Creating $bakDir for backup of any existing dotfiles in home"
        mkdir -p $bakDir
    fi
}
backupExistingDotfile() {
    if [[ -e $HOME/.$1 && ! -L $HOME/.$1 ]]; then
        echo "Backing up existing dotfile: $HOME/.$1 to $bakDir/.$1.bak.0 ..."
        move_and_rotate_backups $HOME/.$1 $bakDir 9
    fi
}
createSymbolicLink() {
    if [[ ! -L $HOME/.$1 ]]; then
        echo "Linking to $1 in home directory"
        ln -s $dotDir/$1 $HOME/.$1
    fi
}
createCopy() {
    [[ -L $HOME/.$1 ]] && rm $HOME/.$1
    if [[ ! -e $HOME/.$1 ]]; then
        echo "Copying $1 to home directory"
        cp $dotDir/$1 $HOME/.$1
    fi
}
createMyBashlibFile() {
    my_bashlib=$scriptPath/bashlib/my_bashlib.sh
    my_file=$HOME/.bashlib/people/$myself.sh
    if [[ ! -e $my_file ]]; then  
        echo -e "Creating empty $my_file"
        echo -e "Add all user specific customizations to $my_file"
        touch $my_file
    fi
    if [[ ! -e $my_bashlib ]]; then 
        echo -e "Creating $my_bashlib"
        echo -e "### Projects \n" >> $my_bashlib
        echo -e "### People" >> $my_bashlib
        echo -e "source $my_file \n" >> $my_bashlib
    fi
}
installSpf13Vim() {
    if [[ -e spf13-vim.lock ]]; then
        echo "remove spf13-vim.lock to reinstall" && return 0
    fi
    echo -e "Installing spf-13 vim distribution..."
    curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
    touch spf13-vim.lock
}
setupGitConfig() {
    read -r -p "Enter Git user.name: " user_name
    read -r -p "Enter Git user.email: " user_email
    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
}
setupGitIgnore() {
    if [[ -e /opt/boxen/bin/boxen-git-credential ]]; then
        git config --global credential.helper "/opt/boxen/bin/boxen-git-credential"
    fi
    if [[ -e /opt/boxen/config/git/gitignore ]]; then
        echo "### Boxen gitignore" >> ~/.gitignore_global
        cat /opt/boxen/config/git/gitignore >> ~/.gitignore_global
    fi
}

### Main
set -e # Exit on any error
[[ ! -e $scriptPath/bashlib ]] && echo "Error: missing bashlib directory" && exit 1

source $scriptPath/bashlib/rotate.sh
confirmBackup
createBackupDir

# Backup any existing dotfiles in homedir to backup directory,
# then create symlinks from the homedir to any files in the
# ~/dotfiles directory specified in $files
for file in $files; do
    backupExistingDotfile $file
    createSymbolicLink $file
done

# Git Config
backupExistingDotfile gitconfig
createCopy gitconfig
setupGitConfig

# Git Ignore
backupExistingDotfile gitignore_global
createCopy gitignore_global
setupGitIgnore

# Personal file
createMyBashlibFile

### Extra configuration
installSpf13Vim

