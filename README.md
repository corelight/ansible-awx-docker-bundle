<img src="https://corelight.com/_nuxt/img/assets/images/logo-corelight-ac156d2.png" width=300 alt="corelight">

# Corelight Ansible AWX Docker Bundle

Note: To download and setup with a single command:
> source <( curl https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/quick-start.sh)

## Table of contents

- [Corelight Ansible AWX Docker Bundle](#corelight-ansible-awx-docker-bundle)
  - [Table of contents](#table-of-contents)
  - [About](#about)
  - [Run-me-first Script](#run-me-first-script)
  - [System Requirements](#system-requirements)
  - [Post-install](#post-install)
  - [Accessing AWX and GitLab](#accessing-awx-and-gitlab)
  - [License](#license)

## About

The purpose of this repository is to install AWX, GitLab, Suricata-update (with Suricata), and other supporting applications, in a local Docker environment

AWX provides a web-based user interface, REST API, and task engine built on top of [Ansible](https://github.com/ansible/ansible). It is the upstream project for [Tower](https://www.ansible.com/tower), a commercial derivative of AWX.

To learn more about using AWX, and Tower, view the [Tower docs site](http://docs.ansible.com/ansible-tower/index.html).

## Run-me-first Script

The run-me-first.sh script will install/setup the following prerequisites:  (It is recommended to run this on a dedicated image.)

- Python3 - version 3.8.5+
- Python3-pip - version 20.3+
- Python3 virtual environment
- [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html) - version 2.10.4
- [Docker](https://docs.docker.com/engine/installation/) - Version 20.10.1+
- [docker](https://pypi.org/project/docker/) Python module - version 4.4.0+
- [docker-compose](https://pypi.org/project/docker-compose/) Python module - version 1.27.4+
- [community.general.docker_image collection](https://docs.ansible.com/ansible/latest/collections/community/general/docker_image_module.html)
- [GNU Make](https://www.gnu.org/software/make/)
- [Git](https://git-scm.com/) - version 2.25.1+
- [AWX](https://github.com/ansible/awx) - version 16.0.0 in a Docker container
- [AWX-Logo](https://github.com/ansible/awx-logos.git)
- Redis for AWX in a Docker container
- postgres for AWX - version 10+ in a Docker container
- [GitLab](https://docs.gitlab.com/omnibus/docker/) - version 13.6.3-ee in a Docker container
- [GitLab Runner](https://docs.gitlab.com/runner/install/docker.html) in a Docker container
- [Suricata](https://suricata.readthedocs.io/en/suricata-5.0.5/what-is-suricata.html) - version 5.0.5 in a Docker container
- [Suricata-update](https://suricata-update.readthedocs.io/en/latest/) - version 1.2+ in the same Docker container as Suricata

## System Requirements

The system that runs the AWX service will need to satisfy the following requirements

- At least 4GB of memory
- At least 2 cpu cores
- At least 20GB of space
- Running Docker, Openshift, or Kubernetes
- If you choose to use an external PostgreSQL database, please note that the minimum version is 10+.

GitLab System Requirements

- minimum 4 cores (supports 500 users)
- minimum 4GB of memory (supports 500 users)
- storage requirements depends on the size of repositories

GitLab Runner Requirements

- a single job in a single instance
  - 1vPU
  - 3.75GB of memory

## Post-install

After the playbook run completes, Docker starts a series of containers that provide the services that make up AWX and the other services mentioned above.  You can view the running containers using the `docker ps` command.

Immediately after the containers start, the *awx_task* container will perform required setup tasks, including database migrations. These tasks need to complete before the web interface can be accessed. To monitor the progress, you can follow the container's STDOUT by running the following:

Additionally, immediately after the containers start, GitLab will perform some initial tasks that must be completed before the web interface is available on HTTP port 8330.  Those tasks can take about 3 minutes to complete.

```bash
# Tail the awx_task log
$ docker logs -f awx_task
```

For AWX you will see output similar to the following:

```bash
Using /etc/ansible/ansible.cfg as config file
127.0.0.1 | SUCCESS => {
    "changed": false,
    "db": "awx"
}
Operations to perform:
  Synchronize unmigrated apps: solo, api, staticfiles, messages, channels, django_extensions, ui, rest_framework, polymorphic
  Apply all migrations: sso, taggit, sessions, sites, kombu_transport_django, social_auth, contenttypes, auth, conf, main
Synchronizing apps without migrations:
  Creating tables...
    Running deferred SQL...
  Installing custom SQL...
Running migrations:
  Rendering model states... DONE
  Applying contenttypes.0001_initial... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0001_initial... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying taggit.0001_initial... OK
  Applying taggit.0002_auto_20150616_2121... OK
  Applying main.0001_initial... OK
...
```

Once migrations complete, you will see the following log output, indicating that migrations have completed:

```bash
Python 2.7.5 (default, Nov  6 2016, 00:28:07)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-11)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
(InteractiveConsole)

>>> <User: admin>
>>> Default organization added.
Demo Credential, Inventory, and Job Template added.
Successfully registered instance awx
(changed: True)
Creating instance group tower
Added instance awx to tower
(changed: True)
...
```

## Accessing AWX and GitLab

The AWX web server is accessible on the deployment host, using the *host_port* value set in the *inventory* file. The default URL is [http://localhost](http://localhost).

You will prompted with a login dialog. The default administrator username is `admin`, and the password is `password`.

The GitLab web server is accessible on the depolyment host using HTTP on port 8330.  The default URL is [http://localhost:8330](http://localhost:8330).

The default username for GitLab is `root`.  The first time you connect you will be prompted to change the password.


## License

[Apache v2](./LICENSE.md)
