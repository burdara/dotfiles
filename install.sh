#!/bin/bash
#
# This script creates symbolic links from the
# home directory to files managed here.
#

### Variables

dotDir=~/dotfiles        # dotfiles directory
bakDir=~/dotfiles/backups    # dotfiles backup directory
mkdir -p $bakDir
# Create list of files/folders to symlink in homedir
files="$(ls | grep -vE "(README.md|backups|make_home_links.sh)")"


### Main
set -e                   # Exit on any error

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -d $scriptPath/bashlib ]]; then
    source $scriptPath/bashlib/rotate.sh
else
    echo "Error:  missing bashlib dir"
    exit 1
fi

echo -e "\nThis will create symlinks from home dir to $dotDir, and backup any existing home dir files to $bakDir:\n\n$files\n"
read -p "Continue? (y/n) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting."; exit
fi
echo "\n"

if [[ ! -d $bakDir ]];then
    echo -e "Creating $bakDir for backup of any existing dotfiles in home ..."
    mkdir -p $bakDir
fi

# Backup any existing dotfiles in homedir to backup directory,
# then create symlinks from the homedir to any files in the
# ~/dotfiles directory specified in $files
homeDir=$( echo ~ )
for file in $files; do
    if [[ -e ~/.$file ]]; then
        echo "Backing up existing dotfile: $homeDir/.$file to $bakDir/.$file.bak.0 ..."
        command="move_and_rotate_backups $homeDir/.$file $bakDir 9"
    $command
    fi
    echo "Linking to $file in home directory"
    command="ln -s $dotDir/$file $homeDir/.$file"
    $command
done

### Extra configuration
echo -e "Installing spf-13 vim distribution..."
curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh

# Customize the spf-13 distro with some local links
echo -e "Remember to hook in spf-13 customizations
    ln -s $scriptPath/dotfiles/vimrc.local ~/.spf13-vim-3/.vimrc.local
    ln -s $scriptPath/dotfiles/vimrc.before ~/.spf13-vim-3/.vimrc.before
"

