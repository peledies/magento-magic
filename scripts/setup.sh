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


# Clone the current laravel repo
echo_start
echo -n "${gold}Creating Magento project with Composer${default}"
  #composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $1
test_for_success $?

cd $1

source $SCRIPTPATH/build_vagrantfile.sh
