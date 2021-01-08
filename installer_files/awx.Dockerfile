FROM ansible/awx:16.0.0
USER root

RUN python3 -m pip uninstall -y ansible \
    && python3 -m pip install -U pip \
    && python3 -m pip install -U ansible==2.10.4 \
    && dnf -y config-manager --add-repo https://releases.ansible.com/ansible-tower/cli/ansible-tower-cli-centos8.repo \
    && dnf -y install ansible-tower-cli
USER 1000
