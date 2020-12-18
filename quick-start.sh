#!/bin/bash
# to download and run this script in one command, execute the following:
# source <( curl https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/quick-start.sh)

echo -e "\033[0;33m";
echo "The script you are about to run will do the following depending on the OS:"
echo ""
echo "  [ ] Install/Upgrade epel-release, libselinux-python dnf (RHEL7/CentOS7)"
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

sudo mkdir /etc/corelight-env
cd /etc/corelight-env
sudo chown $USER.$USER /etc/corelight-env
cd /etc/corelight-env

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS="$(lowercase "$(uname)")"
KERNEL="$(uname -r)"
MACH="$(uname -m)"

if [ "${OS}" == "windowsnt" ]; then
  OS=windows
elif [ "${OS}" == "darwin" ]; then
  OS=mac
else
  OS=$(uname)
  if [ "${OS}" = "SunOS" ] ; then
    OS=Solaris
    ARCH=$(uname -p)
    OSSTR="${OS} ${REV}(${ARCH} $(uname -v))"
  elif [ "${OS}" = "AIX" ] ; then
    OSSTR="${OS} $(oslevel) ($(oslevel -r))"
  elif [ "${OS}" = "Linux" ] ; then
    if [ -f /etc/redhat-release ] ; then
      DistroBasedOn='RedHat'
      DIST=$(sed s/\ release.*//  /etc/redhat-release)
      PSUEDONAME=$(sed s/.*\(// /etc/redhat-release | sed s/\)//)
      REV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*//)
      MREV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*// | sed s/\\..*//)
    elif [ -f /etc/SuSE-release ] ; then
      DistroBasedOn='SuSe'
      PSUEDONAME=$(tr "\n" ' ' /etc/SuSE-release | sed s/VERSION.*//)
      REV=$(tr "\n" ' ' /etc/SuSE-release | sed s/.*=\ //)
      MREV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*// | sed s/\\..*//)
    elif [ -f /etc/mandrake-release ] ; then
      DistroBasedOn='Mandrake'
      PSUEDONAME=$(sed s/.*\(// /etc/mandrake-release | sed s/\)//)
      REV=$( sed s/.*release\ // /etc/mandrake-release |sed s/\ .*//)
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
    if [ -f /etc/UnitedLinux-release ] ; then
      DIST="${DIST}[$(tr "\n" ' ' /etc/UnitedLinux-release | sed s/VERSION.*//)]"
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

fi

echo "$DIST" "$REV"

if [ "$DistroBasedOn" = "redhat" ]; then
        if [ "$MREV" = "7" ]; then
                echo "Installing Python3-pip and other dependencies"
                sudo yum install -y epel-release libselinux-python dnf
                sudo dnf install -y -q python3-pip git
                sudo dnf install -y -q libselinux-python3
        else
                echo "Installing Python3-pip and other dependencies"
                sudo yum install -y dnf
                sudo dnf install -y -q python3-pip git
        fi
elif [ "$DistroBasedOn" = "debian" ]; then
        sudo apt-get update -y -q
        sudo apt-get install -y -q --install-suggests python3-pip git
        sudo apt-get install -y -q --install-suggests python3-venv
else
        echo "Not RedHat or Debian based"
        exit 1
fi


if ! [ -d /etc/corelight-env/ ] > /dev/null; then
        echo "Creating /etc/corelight-env directory"
        sudo mkdir /etc/corelight-env
        sudo chown "$USER"."$USER" /etc/corelight-env
fi

if ! [ -d /etc/ansible/ ] > /dev/null; then
        echo "Creating /etc/ansible directory"
        sudo mkdir /etc/ansible
        sudo chown "$USER"."$USER" /etc/ansible
        sudo chmod 755 /etc/ansible
fi

echo "Creating python3 virtual environment"
python3 -m venv /etc/corelight-env
source /etc/corelight-env/bin/activate
cd /etc/corelight-env/
python3 -m pip install --upgrade pip wheel setuptools

echo "Installing Ansible"
python3 -m pip install --upgrade --upgrade-strategy eager ansible
ansible-galaxy collection install community.general -c

echo "Coping Ansible default config to /etc/ansible/ansible/cfg"
curl https://raw.githubusercontent.com/corelight/Corelight-Ansible-Roles/awx-devel/roles/ansible_install/files/default-ansible.cfg  -o /etc/ansible/ansible.cfg

git clone https://github.com/corelight/ansible/ansible-awx-docker-bundle.git
git clone https://github.com/ansible/awx-logos.git


if [ "$DistroBasedOn" = "redhat" ]; then
        exit 1
       # if [ "$MREV" = "7" ]; then
              #  echo "Installing Python3-pip and other dependencies"
              #  sudo yum install -y epel-release libselinux-python dnf
              #  sudo dnf install -y -q python3-pip git
              #  sudo dnf install -y -q libselinux-python3
       # else
              #  echo "Installing Python3-pip and other dependencies"
              #  sudo yum install -y dnf
              #  sudo dnf install -y -q python3-pip git
       # fi
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
        sudo usermod -aG docker $USER
else
        echo "Not RedHat or Debian based"
        exit 1
fi

python3 -m pip install --upgrade docker docker-compose

curl http://ftp.gnu.org/gnu/make/make-4.3.tar.gz -o make-4.3.tar.gz
sudo tar -zxf make-4.3.tar.gz
cd make-4.3
./configure
./build.sh

cd /etc/corelight-env/awx/installer
ansible-playbook -i inventory install.yml
