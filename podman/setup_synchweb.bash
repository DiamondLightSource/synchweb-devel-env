#!/bin/bash
############################################################
# Name          : setup_synchweb.bash
# Description   : Script to setup SynchWeb running in a podman container.  Note, the config.php file should be setup appropriately before running.
# Args          : $1 - name of podman image to create and run - default: 'synchweb-dev', $2 - run initial container setup - default:'1' (run set up)
############################################################
imageName=synchweb-dev
if [ $1 ]
then
    imageName=$1
    echo Creating podman image with name: $imageName
fi

initialSetUp=1 # if '1' do an initial local set up - e.g. copying in the config files
if [ $2 ]
then
    initialSetUp=$2
    if [ $initialSetUp -eq 1 ]
    then
        echo Will run initial set up
    else
        echo Will NOT run initial set up
    fi
fi

if [ ! -d SynchWeb ]
then
    echo Cloning SynchWeb locally
    git clone https://github.com/DiamondLightSource/SynchWeb.git

    echo Setting up web client
    sudo apt-get -y update

    echo Installing node....
    sudo apt-get -y install curl
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install v16.15
# if the above command doesn't work for your linux distro, try either of:
#    sudo dnf module switch-to nodejs:16 
#    module load node/16.15 

    echo Installing webpack
    sudo apt-get -y install webpack

    echo Installing podman
    sudo apt-get -y install podman

    cd SynchWeb/client
    npm install
    cd -
fi

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

echo Building $imageName image...
podman build . -f Dockerfile --format docker -t $imageName --no-cache

echo Starting webpack client...
cd SynchWeb/client
if [ -f index.php ]
then
    unlink index.php
fi
npm run build:dev && export HASH=$(ls dist) && ln -sf dist/${HASH}/index.html index.php
cd -

echo Starting $imageName container
podman run --security-opt label=disable -it -p 8082:8082 \
    --mount type=bind,source=./SynchWeb,destination=/app/SynchWeb \
    $imageName &