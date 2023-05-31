#!/bin/bash
############################################################
helpText="
Name          : run_dev_client.bash
Description   : Script to run the front end as a dev client with hot reloading. Uses the api from the syncweb pod.
Args          : -b - build (i.e. install)
              : -p - use podman for npm (default)
              : -l - use local npm

Prereq: node and npm installed

Trouble shooting: Can you see http://localhost:8082 if not your synchweb pod is not running.
"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; if ! [ $code -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $code."; fi' EXIT # give details of error on exit

buildImage=0
SCRIPT_DIR=`dirname $BASH_SOURCE`

npm_run_dir="."
npm_exec="podman run --security-opt label=disable --rm --name npm_build  --mount type=bind,source=$SCRIPT_DIR/SynchWeb,destination=/usr/src/app --workdir /usr/src/app/client -it -p 9000:9000 node:17 npm"
host="0.0.0.0"

for i in "$@"
do
case $i in
    -b)
    buildImage=1
    ;;
    -p)
    ;;
    -l)
    npm_run_dir=$SCRIPT_DIR/SynchWeb/client
    npm_exec="npm"
    host="localhost"
    ;;
    -h|--help)
    echo "$helpText"
    exit
    ;;
esac
done

if [ $buildImage -eq 1 ]
then

    echo Installing node modules and build
    if [ -f index.php ]
    then
        unlink index.php
    fi
    $npm_exec install
    $npm_exec run build:dev
    export HASH=$(ls -t dist | head -n1) && ln -sf dist/${HASH}/index.html index.php
fi

echo
echo Starting dev on https://localhost:9000/

ipadd=`hostname -I | cut -d ' ' -f1`
cd $npm_run_dir
$npm_exec run serve -- --env port=9000 --env proxy.target=http://$ipadd:8082 --env host=$host
