FROM centos:8.3.2011

ARG suricata_version
RUN dnf -y install dnf-plugins-core
RUN dnf -y install epel-release
RUN dnf -y copr enable "@oisf/suricata-$suricata_version"
RUN dnf -y install suricata

