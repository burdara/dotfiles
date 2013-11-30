#!/usr/bin/env bash
#
# Move and Rotate Backups
#    Backup source file or directory
#    Backup destination target directory
#    # of versions to keep, with suffix "name.#"
#
function move_and_rotate_backups {
    if [[ $# -ne 3 ]];then
        echo -e "Error:  Expect 3 parameters.  Usage:  backup_with_version \$backup_source \$backup_target_dir \$max_backups\nExiting."; exit 1
    fi

    if [[ -e $1 ]]; then
        backup_source=$1
        backupFilename="${backup_source##*/}"
    else
        echo -e "Error:  Backup source file or dir does not exist"; exit 1
    fi

    if [[ -e $2 ]]; then
        backup_target_dir=$2
    else
        echo -e "Error:  Backup destination target dir does not exist"; exit 1
    fi

    if [[ "$3" != "" ]] ; then
         maxBackups=$3
    else
        echo -e "Error:  Must pass in # of backups to keep."; exit 1
    fi

    delete_oldest_backup
    rotate_backups
    move_backup_source
}

function delete_oldest_backup {
    oldest_backup="$backup_target_dir/$backupFilename.bak.$maxBackups"
    if [[ -d $oldest_backup ]]; then
        echo "Deleting oldest backup: $oldest_backup"
        command="rm -rf $oldest_backup"
    	( $command )
    fi
}

function rotate_backups {
    toBak=$maxBackups
    (( fromBak=$maxBackups-1 ))
    for (( toBak=$maxBackups; toBak>=1; toBak-- ));do
        if [[ $toBak -eq $maxBackups ]]; then printf "Rotating backups:  "; fi;
        if [[ -e $backup_target_dir/$backupFilename.bak.$fromBak ]]; then
            printf "$toBak "
            mv $backup_target_dir/$backupFilename.bak.$fromBak $backup_target_dir/$backupFilename.bak.$toBak
        fi
        fromBak="$(($fromBak-1 ))"
    done
    printf " Done.\n"
}

function move_backup_source {
    # Check to see if any properties files already exist in target location
    echo "Moving $backup_source"
    command="mv $backup_source $backup_target_dir/$backupFilename.bak.0"
    ( $command )
}

