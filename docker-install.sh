#!/bin/bash


lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS="$(lowercase "$(uname)")"
KERNEL="$(uname -r)"
MACH="$(uname -m)"

OS=$(uname)
if [ "${OS}" = "Linux" ] ; then
  if [ -f /etc/redhat-release ] ; then
    DistroBasedOn='RedHat'
    DIST=$(sed s/\ release.*//  /etc/redhat-release)
    PSUEDONAME=$(sed s/.*\(// /etc/redhat-release | sed s/\)//)
    REV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*//)
    MREV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*// | sed s/\\..*//)
  elif [ -f /etc/debian_version ] ; then
    DistroBasedOn='Debian'
    if [ -f /etc/lsb-release ] ; then
            DIST=$(grep '^DISTRIB_ID' /etc/lsb-release | awk -F=  '{ print $2 }')
                  PSUEDONAME=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F=  '{ print $2 }')
                  REV=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F=  '{ print $2 }')
                  MREV=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F. '{ print $1 }' | awk -F= '{ print $2 }')
    fi
  fi
  OS=$(lowercase $OS)
  DistroBasedOn=$(lowercase $DistroBasedOn)
  readonly OS
  readonly DIST
  readonly DistroBasedOn
  readonly PSUEDONAME
  readonly REV
  readonly MREV
  readonly KERNEL
  readonly MACH
fi



if [ -z "$PS1" ]; then
      echo "Not running interactively"
else
      echo -e "\033[0;33m";
      echo "$DIST" "$REV"
      echo ""
      echo "The script you are about to run will do the following depending on the OS:"
      echo ""
      echo "  [ ] Install/Upgrade epel-release, libselinux-python (RHEL7/CentOS7)"
      echo "  [ ] Install/Upgrade libselinux-python3 (RHEL7/CentOS7)"
      echo "  [ ] Install/Upgrade Python3 - version 3.8.5+"
      echo "  [ ] Install/Upgrade Python3-pip - version 20.3+"
      echo "  [ ] Install Docker - Version 20.10.1+"
      echo "  [ ] Install docker Python module - version 4.4.0+"
      echo "  [ ] Install docker-compose Python module - version 1.27.4+"
      echo "  "
      read -p "Press any key to continue or CTRL-C to cancel ..."
      echo -e "\033[0m"
      echo ""
fi

if [ "$DistroBasedOn" = "redhat" ]; then
        if [ "$MREV" = "7" ]; then
                sudo yum install -y epel-release libselinux-python
                sudo yum install -y python3-pip git
                sudo yum install -y libselinux-python3
        else
                sudo yum install -y python3-pip git
        fi
elif [ "$DistroBasedOn" = "debian" ]; then
        sudo apt-get update -y -q
        sudo apt-get install -y -q python3-pip git
        sudo apt-get install -y -q python3-venv
else
        echo "Not RedHat or Debian based"
        exit 1
fi



python3 -m pip install --upgrade pip wheel setuptools

echo "Installing Docker"
if [ "$DistroBasedOn" = "redhat" ]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager \
          --add-repo \
          https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
elif [ "$DistroBasedOn" = "debian" ]; then
        sudo apt-get update -y -q
        sudo apt-get install -y -q apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        sudo apt-get autoremove -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) \
          stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
else
        echo "Not RedHat or Debian based"
        exit 1
fi

sudo usermod -aG docker $USER
newgrp docker <<EONG
echo python3 -m pip install --upgrade docker docker-compose
python3 -m pip install --upgrade docker docker-compose

EONG
newgrp $USER
