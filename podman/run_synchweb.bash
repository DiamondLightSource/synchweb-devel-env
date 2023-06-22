#!/bin/bash
############################################################
helpText="
Name          : run_synchweb.bash
Description   : Script to run the SynchWeb in a podman container,
                  and optionally build it. 
Args          : -b - build the image
              : -s - copy setup scripts before run
              : -n <name> name of the container - default: 'synchweb-dev'
              : -7 use php version 7 when building the image (default php version)
              : -5 use php version 5.4 when building the image
              : -d <mount directory> directory in which dls is mounted - default /dls
              : -f tail the logs after start
Prereq: For the pod to mount the images it needs to be mounted on the host
        filesystem in /dls.  You could mount this on your local filesystem 
        with sshfs, if you do make sure it is mounted with -o ro,allow_other"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; if ! [ $code -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $code."; fi' EXIT # give details of error on exit

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
buildImage=0
initialSetUp=0
imageName=synchweb-dev
phpVersion="7"
finalCommand=""
dls_dir="/dls"
getdls=0
for i in "$@"
do
    if [ $getdls -eq 1 ]
    then
        dls_dir=$i
        getdls=0
        if [ ! -d "$dls_dir" ]
        then
            echo "DLS dir not a directory ($dls_dir)"
            exit
        fi
    else
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
            -5)
            phpVersion="5"
            ;;
            -f)
            finalCommand="logs"
            ;;
            -d) 
            getdls=1
            ;;
            -h|--help)
            echo "$helpText"
            exit
            ;;
            *)
            imageName=$i
            ;;
        esac
    fi
done

if [ $getdls -ne 0 ]
then
   echo "No DLS dir given!"
   exit
fi

echo Running podman image with name: $imageName

echo Stop and remove previous container image
podman stop synchweb-dev || echo "Error: Continer not existisng is ok"
podman rm synchweb-dev || echo "Error: Container not existing is ok"

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
    $SCRIPT_DIR/run_dev_client.bash -b -d
    cd $SCRIPT_DIR
fi

# If the dls directory exists then mount it into the container
if [ -d "$dls_dir" ]; then
    echo "DLS dir mounted: $dls_dir"
    mountDLS="--mount type=bind,source=$dls_dir,destination=/dls"
else
    echo "DLS dir NOT mounted is not a directory (tried $dls_dir)"
fi

# To stop composer rate limiting you create a public github token for composer and add it to the file .ssh/id_composer
# (see https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth)
composerTokenFile=~/.ssh/id_composer
if [ -f "$composerTokenFile" ]; then
    token=`cat "$composerTokenFile"`
    COMPOSER_AUTH="{\"github-oauth\": { \"github.com\": \"$token\" } }"
    echo Composer Token: Set
else
    echo Composer Token: None
fi;
    
echo
echo Starting $imageName container as $imageName
podman run --security-opt label=disable -it -p 8082:8082 \
    --env COMPOSER_AUTH="$COMPOSER_AUTH" \
    --mount type=bind,source=$SCRIPT_DIR/SynchWeb,destination=/app/SynchWeb \
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
