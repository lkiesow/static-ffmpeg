#!/bin/bash

set -u
set -e


FFMPEG_DIR="ffmpeg_g$(git rev-parse --short HEAD)_d$(date +%s)"
mkdir -p "$FFMPEG_DIR"

cp ffmpeg_bin/ffmpeg "$FFMPEG_DIR/"
cp ffmpeg_bin/ffprobe "$FFMPEG_DIR/"
mkdir -p "$FFMPEG_DIR/man/man1"
cp ffmpeg_build/share/man/man1/ffmpeg*   "$FFMPEG_DIR/man/man1"
cp ffmpeg_build/share/man/man1/ffprobe*  "$FFMPEG_DIR/man/man1/"
mkdir -p "$FFMPEG_DIR/man/man3"
cp ffmpeg_build/share/man/man3/libav*    "$FFMPEG_DIR/man/man3/"
cp ffmpeg_build/share/man/man3/libsw*    "$FFMPEG_DIR/man/man3/"

mkdir -p ~/.ssh/
chmod 700 ~/.ssh/
echo "$DEPLOY_SSH_KEY_BASE64" | base64 -d -i > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
echo "$DEPLOY_KNOWN_HOSTS" > ~/.ssh/known_hosts
chmod 400 ~/.ssh/known_hosts

scp -P "$DEPLOY_SSH_PORT" -r "$FFMPEG_DIR $DEPLOY_SSH_USER@$DEPLOY_HOSTNAME:$DEPLOY_PATH" | true
