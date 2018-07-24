#!/bin/bash

set -u
set -e


scp -P $DEPLOY_PORT ffmpeg_g$(git rev-parse --short HEAD)_d$(date +%s) $DEPLOY_SSH_USER@$DEPLOY_HOSTNAME:$DEPLOY_PATH
