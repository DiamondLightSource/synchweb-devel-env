#!/bin/bash
############################################################
helpText="
# Name          : setup_synchweb.bash
# Description   : Script to setup SynchWeb running in a podman container.  
                  Note, the config.php file should be setup appropriately before running.
# Args          : $1 - name of podman image to create and run - default: 'synchweb-dev', 
#               : $2 - run initial container setup - default:'1' (run set up)
#               : $3 - install command to use - default:\"sudo apt-get -y\" - adjust for 
                       different linux distros"
############################################################

set -e # exit immediately if any command fails
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; if ! [ $code -eq 0 ]; then echo "\"${last_command}\" command failed with exit code $code."; fi' EXIT # give details of error on exit

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
 echo "$helpText"
 exit 0
fi

imageName=synchweb-dev
if [ $1 ]
then
    imageName=$1
fi
echo Creating and running podman image with name: $imageName

initialSetUp=1 # if '1' do an initial local set up - e.g. copying in the config files
if [ $2 ]
then
    initialSetUp=$2
fi
if [ $initialSetUp -eq 1 ]
then
    echo Will run initial set up
else
    echo Will NOT run initial set up
fi

installCmd="sudo apt-get -y"
if [ $3 ]
then
    installCmd=$3
fi
echo Install linux apps using: $installCmd

SCRIPT_DIR=`dirname $BASH_SOURCE`

if [ ! -d SynchWeb ]
then
    echo Cloning SynchWeb locally
    git clone https://github.com/DiamondLightSource/SynchWeb.git

    echo Setting up web client locally
    $installCmd update

    # set up appropriate version of node to use (v18 will fail with current code)
    echo Installing node....
    $installCmd install curl
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install v16.15
# if the above command doesn't work for your linux distro, try either of:
#   sudo dnf module switch-to nodejs:16 
#   module load node/16.15 

    echo Installing podman
    $installCmd install podman

    cd SynchWeb/client
    npm install

    echo Installing webpack
    npm install webpack
    cd -
fi

if [ $initialSetUp -eq 1 ]
then
    initialSetUpFlag="-s"
else
    initialSetUpFlag=""
fi

$SCRIPT_DIR/run_synchweb.bash -b $initialSetUpFlag $imageName

$SCRIPT_DIR/rebuildClient.bash
