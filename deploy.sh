#!/bin/bash

set -u
set -e


FFMPEG_NAME=ffmpeg_g$(git rev-parse --short HEAD)_d$(date +%s)
mv ffmpeg_bin/ffmpeg $FFMPEG_NAME

mkdir -p ~/.ssh/
chmod 700 ~/.ssh/
echo "$DEPLOY_SSH_KEY" > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
echo "$DEPLOY_KNOWN_HOSTS" > ~/.ssh/known_hosts
chmod 400 ~/.ssh/known_hosts
scp -P $DEPLOY_SSH_PORT $FFMPEG_NAME $DEPLOY_SSH_USER@$DEPLOY_HOSTNAME:$DEPLOY_PATH
