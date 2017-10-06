SHOME='G:\a0a\ileler\configs\upan\..\..\..\'
#!/usr/bin/env sh
source ../ext-cygwin


#global
export __=$(pwd)
export HOME=$__
export HOMEPATH=$HOME
export USERPROFILE=$HOME
export APPDATA=$USERPROFILE/AppData/Roaming
export LOCALAPPDATA=$USERPROFILE/AppData/Local


#COMMON DIR SET
export _USER_COMMON_=$__/../.common
cd $HOME && rm -rf .ssh && ext-link .ssh $_USER_COMMON_/.ssh && cd -


#some software need.(eg: electron)
mkdir -p $APPDATA
export ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/

#nodejs
export _NODEJS_=node-v6.10.0-win-x64
export NODE_HOME=$__/bins/NodeJS
export npm_config_cache=$NODE_HOME/npm-cache
export npm_config_prefix=$NODE_HOME/npm-global
export NODE_PATH=$HOME/.node_modules:$npm_config_prefix/node_modules:$NODE_HOME/$_NODEJS_/node_modules
export NODE_MODULES=$NODE_PATH

#python
export _PYTHON_=Python36-32
export PYTHON_HOME=$__/bins/Python
export PYTHON_SCRIPTS=Scripts
export PYTHONHOME=$PYTHON_HOME/$_PYTHON_

#path
export PATH=$PYTHONHOME:$PYTHONHOME/$PYTHON_SCRIPTS:$NODE_HOME/$_NODEJS_:$npm_config_prefix:$NVM_HOME:$PATH

echo "current PATH:"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>"
echo $PATH
echo "<<<<<<<<<<<<<<<<<<<<<<<<<"

source ~/.bashrc