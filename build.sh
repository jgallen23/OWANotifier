#!/bin/bash

VERSION=$1

cd build/Release
tar -cvzf OWANotifier-$VERSION.tar.gz OWANotifier.app
cd ../..
mv build/Release/OWANotifier-$VERSION.tar.gz .
ruby ~/Dropbox/code/Signing\ Tools/sign_update.rb OWANotifier-$VERSION.tar.gz ~/Dropbox/code/_keys/owanotifier_priv.pem
