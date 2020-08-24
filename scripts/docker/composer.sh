#!/bin/sh
docker run --rm -ti --user $(id -u):$(id -g) \
    --volume ~/.config/composer:/tmp \
    --volume $SSH_AUTH_SOCK:/ssh-auth.sock \
    --volume /etc/passwd:/etc/passwd:ro \
    --volume /etc/group:/etc/group:ro \
    --volume $(pwd):/app \
    --env SSH_AUTH_SOCK=/ssh-auth.sock \
    composer $@
