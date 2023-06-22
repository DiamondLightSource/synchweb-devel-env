#!/bin/bash
############################################################
helpText="
Name          : run_dev_client.bash
Description   : Script to run the front end as a dev client with hot reloading. Uses the api from the syncweb pod.
Args          : -b - build (i.e. install)
              : -ci - build and install using npm ci
              : -p - use podman for npm (default)
              : -l - use local npm
              : -d - don't run just build (default is to run the client)

Prereq: node and npm installed

Trouble shooting: Can you see http://localhost:8082 if not your synchweb pod is not running.
"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; if ! [ $code -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $code."; fi' EXIT # give details of error on exit

buildImage=0
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
npm_run_dir="."
podname=npm_build
npm_exec="podman run --security-opt label=disable --ulimit nofile=4096:4096 --rm --name $podname --mount type=bind,source=$SCRIPT_DIR/SynchWeb,destination=/usr/src/app --workdir /usr/src/app/client -it -p 9000:9000 node:18-bullseye npm"
host="0.0.0.0"
dont_run=0
test=0
installcmd="install"

local_client_dir=$SCRIPT_DIR/SynchWeb/client

for i in "$@"
do
case $i in
    -t)
    test=1
    ;;
    -b)
    buildImage=1
    ;;
    -ci)
    installcmd="ci"
    ;;
    -p)
    ;;
    -l)
    npm_run_dir=$local_client_dir
    npm_exec="npm"
    host="localhost"
    podname=""
    ;;
    -d)
    dont_run=1
    ;;
    -h|--help)
    echo "$helpText"
    exit
    ;;
esac
done

if [ "$podname" = "" ]
then
    podman kill $podname | echo "."
    podman rm  $podname | echo "."
fi

if [ $buildImage -eq 1 ]
then

    echo Installing node modules and build
    if [ -f "$local_client_dir/index.php" ]
    then
        echo unlinking
        unlink $local_client_dir/index.php
    fi
    cd $npm_run_dir
    $npm_exec $installcmd
    $npm_exec run build:dev
    export HASH=$(ls -t $local_client_dir/dist | head -n1 | cut -d " " -f 1) && ln -sf dist/${HASH}/index.html $local_client_dir/index.php
fi

if [ $test -eq 1 ] 
then
    $npm_exec run test
fi

if [ $dont_run -eq 1 ]
then
    exit
fi

echo
echo Starting dev on https://localhost:9000/

ipadd=`hostname -I | cut -d ' ' -f1`
cd $npm_run_dir
$npm_exec run serve -- --env port=9000 --env proxy.target=http://$ipadd:8082 --env host=$host
