#!/bin/bash
############################################################
helpText="
Name          : run_synchweb.bash
Description   : Script to run the SynchWeb in a podman container,
                  and optionally build it. 
Args          : -b - build the image
              : -s - copy setup scripts before run
              : -n <name> name of the container - default: 'synchweb-dev'
              : -7 use php version 7 instead of 5.4 when building the image
              : -f tail the logs after start
Prereq: For the pod to mount the images it needs to be mounted on the host
        filesystem in /dls.  You could mount this on your local filesystem 
        with sshfs, if you do make sure it is mounted with -o ro,allow_other"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; if ! [ $code -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $code."; fi' EXIT # give details of error on exit

buildImage=0
initialSetUp=0
imageName=synchweb-dev
phpVersion="5"
finalCommand=""
dls_dir="/dls"

for i in "$@"
do
case $i in
    -b)
    buildImage=1
    ;;
    -s)
    initialSetUp=1
    ;;
    -7)
    phpVersion="7"
    ;;
    -f)
    finalCommand="logs"
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

echo Stop and remove previous container image
podman stop --ignore synchweb-dev
podman rm --ignore synchweb-dev

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

    echo Building $imageName image
    if [ "$phpVersion" = "7" ]; then
        dockerFieldSuffic="-7.4.dockerfile"
    fi
    podman build . -f Dockerfile$dockerFieldSuffic --format docker -t $imageName --no-cache

    echo Building webpack client
    cd SynchWeb/client
    if [ -f index.php ]
    then
        unlink index.php
    fi
    npm run build:dev && export HASH=$(ls -t dist | head -n1) && ln -sf dist/${HASH}/index.html index.php
    cd -
fi

# If the dls directory exists then mount it into the container
if [ -d "$dls_dir" ]; then
    mountDLS="--mount type=bind,source=$dls_dir,destination=/dls"
fi

# To stop composer rate limiting you create a public github token for composer and add it to the file .ssh/id_composer
# (see https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth)
composerTokenFile=~/.ssh/id_composer
if [ -f "$composerTokenFile" ]; then
    token=`cat "$composerTokenFile"`
    COMPOSER_AUTH="{\"github-oauth\": { \"github.com\": \"$token\" } }"
fi;
    
echo
echo Starting $imageName container as $imageName
podman run --security-opt label=disable -it -p 8082:8082 \
    --env COMPOSER_AUTH="$COMPOSER_AUTH" \
    --mount type=bind,source=./SynchWeb,destination=/app/SynchWeb \
    $mountDLS \
    --name=$imageName --detach \
    $imageName 

case "$finalCommand" in
  "logs")
  podman logs -f synchweb-dev
  ;;
  *)
  echo " See logs: podman logs -f synchweb-dev"
  echo "Enter pod: podman exec -it synchweb-dev /bin/bash"
  ;;
esac
