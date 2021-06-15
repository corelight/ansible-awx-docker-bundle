#!/bin/bash
# to download and run this script in one command, execute the following:
# source <( curl https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/quick-start.sh)

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
      echo "  [ ] Create a Python3 virtual environment at /etc/corelight-env/"
      echo "  [ ] Install Ansible in the /etc/corelight-env/ virtual environment - version 2.10.4"
      echo "  [ ] Install Docker - Version 20.10.1+"
      echo "  [ ] Install docker Python module - version 4.4.0+"
      echo "  [ ] Install docker-compose Python module - version 1.27.4+"
      echo "  [ ] Install/Upgrade Ansible community.general collection"
      echo "  [ ] Install/Upgrade GNU Make"
      echo "  [ ] Install/Upgrade Git - version 2.25.1+"
      echo "  [ ] Install/Upgrade AWX - version 16.0.0 in a Docker container"
      echo "  [ ] Install Ansible in the AWX container - version 2.10.4"
      echo "  [ ] Install Redis for AWX in a Docker container"
      echo "  [ ] Install postgres for AWX - version 10+ in a Docker container"
      echo "  [ ] Install GitLab - version 13.6.3-ee in a Docker container"
      echo "  [ ] Install GitLab Runner in a Docker container"
      echo "  [ ] Install Suricata - version 5.0.5 in a Docker container"
      echo "  [ ] Install Suricata-update - version 1.2+ in the same Docker container as Suricata"
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

echo "Creating python3 virtual environment"
if ! [ -d /etc/corelight-env/ ] > /dev/null; then
        echo "Creating /etc/corelight-env directory"
        sudo mkdir /etc/corelight-env
        sudo chown "$USER"."$USER" /etc/corelight-env
fi
python3 -m venv /etc/corelight-env
source /etc/corelight-env/bin/activate

python3 -m pip install --upgrade pip wheel setuptools

cd /etc/corelight-env/
git clone https://github.com/ansible/awx-logos.git

mkdir /etc/corelight-env/var/
mkdir /etc/corelight-env/var/run/

mkdir /etc/corelight-env/awx
mkdir /etc/corelight-env/awx/projects
mkdir /etc/corelight-env/.awx
mkdir /etc/corelight-env/.awx/awxcompose
mkdir /etc/corelight-env/.awx/awxcompose/redis_socket
sudo chmod 755 -R /etc/corelight-env/
sudo chmod 777 /etc/corelight-env/.awx/awxcompose/redis_socket
cd /etc/corelight-env/.awx/awxcompose
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/environment.sh
sudo chmod 600 environment.sh
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/credentials.py
sudo chmod 600 credentials.py
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/docker-compose.yml
sudo chmod 600 docker-compose.yml
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/awx.Dockerfile
sudo chmod 600 awx.Dockerfile
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/centos8-suricata.Dockerfile
sudo chmod 600 centos8-suricata.Dockerfile
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/nginx.conf
sudo chmod 600 nginx.conf
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/redis.conf
sudo chmod 664 redis.conf
curl -O https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/installer_files/SECRET_KEY
sudo chmod 600 SECRET_KEY

BROADCAST_WEBSOCKET_SECRET=$(base64 /dev/urandom | tr -d '/+' | dd bs=128 count=1 2>/dev/null)
echo BROADCAST_WEBSOCKET_SECRET = \"$BROADCAST_WEBSOCKET_SECRET\" >> credentials.py

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
        sudo apt-get install -y -q --install-suggests apt-transport-https \
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

curl http://ftp.gnu.org/gnu/make/make-4.3.tar.gz -o make-4.3.tar.gz
sudo tar -zxf make-4.3.tar.gz
cd make-4.3
./configure
./build.sh

cd /etc/corelight-env/.awx/awxcompose

echo docker-compose up -d
docker-compose up -d
docker exec awx_web '/usr/bin/update-ca-trust'
docker exec awx_task '/usr/bin/update-ca-trust'
EONG
newgrp $USER
