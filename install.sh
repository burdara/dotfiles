#!/usr/bin/env bash
#
# This script creates symbolic links from the
# home directory to files managed here.

myself=$(whoami)
dot_dir="$HOME/dotfiles"
backup_dir="$HOME/dotfiles/backups"
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
max_backups=9

# Create list of files/folders to symlink in homedir
files="$(ls | grep -vE '(README.md|backups|install.sh|spf13-vim.sh|gitconfig|gitignore_global)')"

confirm_backup() {
  echo -e "\nThis will create symlinks from $dot_dir to $HOME, and backup any existing home dir files to $backup_dir:\n\n$files\n"
  read -p "Continue? (y/n) " -n 1 -r
  [[ "$REPLY" != "y" ]] && echo "Exiting." && exit 0
  echo "Let's do this!"
}

create_backup_dir() {
  [[ ! -d $backup_dir ]] \
    && echo -e "Creating $backup_dir for backup of any existing dotfiles in home"
    && mkdir -p $backup_dir
}

move_and_rotate_backup() {
    [[ -z "$1" ]] && echo -e "Error: backup_source arg not specified. " \
      && local rc=1
    [[ -z "$2" ]] && echo -e "Error: backup_target_dir arg not specified. " \
      && local rc=1
    [[ -z "$3" ]] && echo -e "Error: max_backups arg not specified. " \
      && local rc=1
    [[ ! -e "$1" ]] && echo -e "Error: backup_source path does not exist." \
      && local rc=2
    [[ ! -d "$2" ]] \
      && echo -e "Error: backup_target_dir directory does not exist." \
      && local rc=2
    [[ "$rc" -ne 0 ]] \
      && echo -e "Usage: move_and_rotate_backups backup_source backup_target_dir max_backups" \
      && return $rc

    # delete oldest backups
    local oldest_backup="$2/${1##*/}.bak.$3"
    [[ -e $oldest_backup ]] && echo "Deleting oldest backup: $oldest_backup" \
      && rm -rf "$oldest_backup"

    # rotate backups
    to_bkp="$3"
    from_bkp="$(($3-1))"
    for (( to_bkp=$3; to_bkp >= 1; to_bkp-- )); do
      [[ "$to_bak" == "$3" ]] && echo "Rotating backups: "
      if [[ -e $2/${1##*/}.bkp.$from_bkp ]]; then
        printf "$to_bkp "
        mv $2/${1##*/}.bkp.$from_bkp $2/${1##*/}.bkp.$to_bkp
      fi
      from_bkp="$(($from_bkp-1))"
    done
    printf " Done.\n"

    # Move backups
    mv $1 $2/${1##*/}.bak.0
}

backup_existing_dotfile() {
  [[ -z "$1" ]] && echo -e "Error: dotfile arg not specified. " && return 1
  [[ -e $HOME/.$1 && ! -L $HOME/.$1 ]] \
    && echo "Backing up existing dotfile: $HOME/.$1 to $backup_dir/.$1.bak.0 ..." \
    && move_and_rotate_backup "$HOME/.$1" "$backup_dir" "$max_backups"
}

create_symbolic_link() {
  [[ -z "$1" ]] && echo -e "Error: dotfile arg not specified. " && return 1
  [[ ! -L $HOME/.$1 ]] && echo "Linking to $1 in home directory" \
    && ln -s $dot_dir/$1 $HOME/.$1
}

create_copy() {
  [[ -z "$1" ]] && echo -e "Error: dotfile arg not specified. " && return 1
  [[ -L $HOME/.$1 ]] && rm $HOME/.$1
  [[ ! -e $HOME/.$1 ]] && echo "Copying $1 to home directory" \
    && cp $dot_dir/$1 $HOME/.$1
}

create_my_bashlib_file() {
  for dir in custom; do
    [[ ! -d $HOME/.bashlib/$dir ]] && mkdir -p $HOME/.bashlib/$dir
  done
  my_bashlib=$script_path/bashlib/my_bashlib.sh
  my_file=$HOME/.bashlib/people/$myself.sh
  [[ ! -e $my_file ]] && echo -e "Creating empty $my_file" \
    && echo -e "Add all user specific customizations to $my_file" \
    && touch $my_file
  [[ ! -e $my_bashlib ]] \
    && echo -e "Creating $my_bashlib" \
    && echo -e "# Projects \n" >> $my_bashlib \
    && echo -e "# People" >> $my_bashlib \
    && echo -e "source $my_file \n" >> $my_bashlib
}

install_spf13_vim() {
  [[ -e spf13-vim.lock ]] \
    && echo "remove spf13-vim.lock to reinstall" && return 0
  echo -e "Installing spf-13 vim distribution..."
  curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
  touch spf13-vim.lock
}

### Main
set -e # Exit on any error
[[ ! -d "$script_path/bashlib" ]] && echo "Error: missing bashlib directory" && exit 1

source "$script_path/bashlib/rotate.sh"
confirm_backup
create_backup_dir

# Backup any existing dotfiles in homedir to backup directory,
# then create symlinks from the homedir to any files in the
# ~/dotfiles directory specified in $files
for file in $files; do
  backup_existing_dotfile "$file"
  create_symbolic_link "$file"
done

# Git Config
backup_existing_dotfile "gitconfig"
create_copy "gitconfig"

# Git Ignore
backup_existing_dotfile "gitignore_global"
create_copy "gitignore_global"

# Personal file
create_my_bashlib_file

### Extra configuration
install_spf13_vim
