#!/bin/sh
set -e

# host option
if [ -z "$WERCKER_RSYNC_DEPLOY_HOST" ]
then
    fail 'missing host option, please add this the rsync-deploy step in wercker.yml'
fi

# directory option
if [ -z "$WERCKER_RSYNC_DEPLOY_DIRECTORY" ]
then
    fail 'missing directory option, please add this the rsync-deploy step in wercker.yml'
fi

# user option
remote_user="ubuntu"
if [ -n "$WERCKER_RSYNC_DEPLOY_USER" ]; # Check $WERCKER_BUNDLE_INSTALL exists and is not empty
then
    remote_user="$WERCKER_RSYNC_DEPLOY_USER"
fi
info "using user $remote_user"

# port option
remote_port="22"
if [ -n "$WERCKER_RSYNC_DEPLOY_SSHPORT" ]; # Check $WERCKER_RSYNC_DEPLOY_SSHPORT exists and is not empty
then
    remote_port="$WERCKER_RSYNC_DEPLOY_SSHPORT"
fi
info "using remote port $remote_port"

# key option
rsync_command="ssh -o BatchMode=yes -p $remote_port" # Batchmode to prevent it from waiting on user input
if [ -n "$WERCKER_RSYNC_DEPLOY_SSHKEY" ]
then
    rsync_command="$rsync_command -i $WERCKER_RSYNC_DEPLOY_SSHKEY"
fi

source_dir="./"
if [ -n "$WERCKER_RSYNC_DEPLOY_SOURCE" ]; # check if source dir is specified
then
    source_dir=$WERCKER_RSYNC_DEPLOY_SOURCE
fi

info "Synchronizing $source_dir to $remote_user@$WERCKER_RSYNC_DEPLOY_HOST:$WERCKER_RSYNC_DEPLOY_DIRECTORY..."
sync_output=$(rsync -urltv --rsh="$rsync_command" "$source_dir" "$remote_user@$WERCKER_RSYNC_DEPLOY_HOST:$WERCKER_RSYNC_DEPLOY_DIRECTORY")
if [[ $? -ne 0 ]];then
    warning $sync_output
    fail 'rsync failed';
else
    success "finished rsync synchronisation"
fi
