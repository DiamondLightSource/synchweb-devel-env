#!/bin/bash
############################################################
helpText="
Name          : run_dev_client.bash
Description   : Script to run the front end as a dev client with hot reloading. Uses the api from the syncweb pod.
Args          : -b - build (i.e. install)

Prereq: node and npm installed

Trouble shooting: Can you see http://localhost:8082 if not your synchweb pod is not running.
"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; if ! [ $code -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $code."; fi' EXIT # give details of error on exit

buildImage=0

for i in "$@"
do
case $i in
    -b)
    buildImage=1
    ;;
    -h|--help)
    echo "$helpText"
    exit
    ;;
esac
done

cd SynchWeb/client

if [ $buildImage -eq 1 ]
then

    echo Installing node modules
    npm install
fi

echo
echo Starting dev on http://localhost:9000/

npm run serve -- --env port=9000 --env proxy.target=http://localhost:8082
