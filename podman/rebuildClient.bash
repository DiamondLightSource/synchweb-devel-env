#!/bin/bash
echo Building web client...
cd SynchWeb/client
if [ -f index.php ]
then
    unlink index.php
fi

npm run build:dev && export HASH=$(ls dist) && ln -sf dist/${HASH}/index.html index.php
cd -
echo Web client built and linked