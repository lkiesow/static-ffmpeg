# deployment docker of static-ffmpeg

## Usage

Building can be done with `docker-compose up -d`

Removal with `docker-compose down`, you can add the `--rmi all` flags to remove the images build by docker-compose and the `-v` flag to remove the volume used by the docker-containers (, which hold the ffmpeg binaries)

## Needed

1. docker and docker-compose

2. port `2222` should be unused (changeable in docker-compose.yml)

3. In `static-ffmpeg/deploy/ssh-keys`: a `authorized_keys` file, which holds the public key of the deploying server (e.g. circleci)

4. In `static-ffmpeg/deploy/ssh-keys`: a `ssh_host_rsa_key` file, which holds the ssh-key, which should be used by the ssh-server on port `2222`

## CircleCI

Multiple Environment Variables are needed

1. `DEPLOY_HOSTNAME`

2. `DEPLOY_KNOWN_HOSTS`, oneline known hosts file, which should contain the public key of the `ssh_host_rsa_key` key

3. `DEPLOY_PATH` this should be set to `deploy/.`, unless configured otherwise

4. `DEPLOY_SSH_KEY_BASE64` base64 encoded version of the corresponding private key of `authorized_keys`

5. `DEPLOY_SSH_PORT` see 2. above, this should be `2222` unless otherwise configured

6. `DEPLOY_SSH_USER` this should be set to `deploy`, unless a diffrent docker-image is used

