read -p "${cyan}What local port should Vagrant Map to its port ${red}80${cyan}: [default 8000]${gold} " port
http_port=${port:-8000}
read -p "${cyan}What local port should Vagrant Map to its port ${red}3306${cyan}: [default 3307]${gold} " port
mysql_port=${port:-3307}
read -p "${cyan}Magento Public Key:${gold} " magento_public_key
read -p "${cyan}Magento Private Key:${gold} " magento_private_key

configure_generic() {
  echo "${green} Which image do you want to use"
  echo " ===================${normal}"
  echo "${magenta} 1 ${default}- Ubuntu (ubuntu/xenial64)[16.04 LTS]"
  echo "${magenta} 2 ${default}- Generic (hashicorp/precise64)[12.04 LTS]"

  while true; do
    read -p "${cyan} Select an option from the list above: ${gold}" answer
    case $answer in
      1 ) clear; version='xenial'; break;;
      2 ) clear; version='precise'; break;;

      * ) echo "Please select a valid option.";;
    esac
  done
  if [ "$version" == "xenial" ]
  then
    use_image='config.vm.box = "ubuntu/xenial64"'
  else
    use_image='config.vm.box = "hashicorp/precise64"'
  fi

  write_vagrantfile_generic
  create_credentials_file
}


write_vagrantfile_generic(){
# Create new Vagrantfile configuration
echo_start
echo -n "${gold}Creating Generic Vagrantfile${default}"

cat <<EOF > $INITDIR/Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ${use_image}
  
  config.vm.provision "file", source: "./magento_auth.json", destination: "/home/ubuntu/.config/composer/auth.json"

  config.vm.network :forwarded_port, host: ${http_port}, guest: 80
  config.vm.network :forwarded_port, host: ${mysql_port}, guest: 3306

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.synced_folder "./${project}", "/var/www/html", owner: "www-data", group: "www-data", mount_options: ["dmode=777", "fmode=777"]

  config.vm.provision "shell" do |s|
    s.path = "./scripts/magento_generic_bootstrap.sh"
    s.args   = ["$project", "$magento_public_key", "$magento_private_key"]
  end

end
EOF
test_for_success $?
}

create_credentials_file() {

cat <<EOF > $INITDIR/magento_auth.json
{
  "http-basic": {
      "repo.magento.com": {
          "username": "$magento_public_key",
          "password": "$magento_private_key"
      }
  }
}
EOF
}

echo "${green} Select the type of Development Environment"
echo " ===================${normal}"
echo "${magenta} 1 ${default}- Generic Environment"

while true; do
  read -p "${cyan} Select an option from the list above: ${gold}" answer
  case $answer in
    1 ) clear; configure_generic; break;;

    * ) echo "Please select a valid option.";;
  esac
done

