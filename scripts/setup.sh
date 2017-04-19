#!/bin/bash
pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

project=$1
version="2.1.0"

source $SCRIPTPATH/assets/info_box.sh
source $SCRIPTPATH/assets/pretty_tasks.sh

if [ -z "$1" ];then
  echo "${red}You must specify a project name to create.${default}"
  exit 1
fi

source $SCRIPTPATH/build_vagrantfile.sh

cp magento_auth.json ~/.composer/auth.json

# Clone the current laravel repo
echo_start
echo -n "${gold}Creating Project Directory${default}"
  mkdir -p $INITDIR/$1
test_for_success $?

#vagrant up