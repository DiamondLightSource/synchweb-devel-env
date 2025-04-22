#!/bin/bash
echo Building web client...
cd SynchWeb/client
#if [ -f index.php ] || ([ -L index.php ] && ! [ -e index.php ])
#then
echo "Removing index.php..."
rm -f index.php
#fi

npm run build:dev && export HASH=$(ls -t dist | head -n1 | cut -d " " -f 1) && ln -sf dist/${HASH}/index.html index.php
cd -
echo Web client built and linked
