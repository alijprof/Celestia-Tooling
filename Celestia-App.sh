#!/bin/bash

APP_VERSION="v0.13.0"

cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app/
git checkout tags/$APP_VERSION -b $APP_VERSION
make install
