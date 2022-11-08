#!/bin/bash
############################################################
helpText="
Name          : run_synchweb.bash
Description   : Script to run the SynchWeb in a podman container, and optionally build it. 
Args          : -b - build the image
              : -s - copy setup scripts before run
              : -n <name> name of the container - default: 'synchweb-dev'"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'if ! [ $? -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $?."; fi' EXIT # give details of error on exit

buildImage=0
initialSetUp=0
imageName=synchweb-dev

for i in "$@"
do
case $i in
    -b)
    buildImage=1
    ;;
    -s)
    initialSetUp=1
    ;;
    -h|--help)
    echo "$helpText"
    exit
    ;;
    *)
    imageName=$i
    ;;
esac
done

echo Running podman image with name: $imageName

if [ $initialSetUp -eq 1 ]
then
    echo Running initial set up
    if [ -f config.php ] && [ -f php-fpm.conf ] && [ -f entrypoint.bash ] && [ -f httpd.conf ]
    then 
        cp config.php SynchWeb/api/
        if [ -f php.ini ]
        then
            cp php.ini SynchWeb/
        fi
        cp php-fpm.conf SynchWeb/
        cp entrypoint.bash SynchWeb/
    else
        echo Missing file - need to have config.php, php-fpm.conf, entrypoint.bash and httpd.conf in this directory
        exit 1
    fi
    chmod 755 SynchWeb/entrypoint.bash
fi

if [ $buildImage -eq 1 ]
then

    echo Building $imageName image...
    podman build . -f Dockerfile --format docker -t $imageName --no-cache

    echo Building webpack client...
    cd SynchWeb/client
    if [ -f index.php ]
    then
        unlink index.php
    fi
    npm run build:dev && export HASH=$(ls -t dist | head -n1) && ln -sf dist/${HASH}/index.html index.php
    cd -
fi

echo Stop and remove previous container image
podman stop --ignore synchweb-dev
podman rm --ignore synchweb-dev

echo
echo Starting $imageName container as $imageName
podman run --security-opt label=disable -it -p 8082:8082 \
    --mount type=bind,source=./SynchWeb,destination=/app/SynchWeb \
    --name=$imageName --detach $imageName 
 
