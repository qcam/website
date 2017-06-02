{
  "title": "Provision AliCloud",
  "slug": "provision-alicloud",
  "date": "2016-03-14",
  "description": "This post shares how our application Dadadee, which is written in Ruby on Rails, is built and deployed",
  "keywords": ["alicloud", "alibaba cloud", "provision", "ansible"],
  "tags": ["devops"]
}
---
Last month we @ Dadadee were pretty excited to start moving off from [Amazon Web Service](https://aws.amazon.com/) to [AliCloud](https://intl.aliyun.com/).
This post shares how our application, written in Ruby on Rails, is built and deployed.

---
Last month we @ Dadadee were pretty excited to start moving off from [Amazon Web Service](https://aws.amazon.com/) to [AliCloud](https://intl.aliyun.com/).
This post shares how our application, written in Ruby on Rails, is built and deployed.

Note: I assume you have some experience with Ansible and Docker.

### Create your instance on AliCloud

Let's initiate a Generation II, 2-core and 4GB RAM instance.

Although sometimes the console is buggy, generally AliCloud is quite easy to start off.

Please note to set your root password, in order to SSH later.

### Provision your server with Ansible

As of I wrote this post, AliCloud's apt mirror was still inaccessible, so we will need to choose another alternative mirror

```
- name: Update sources.list
  copy: src="sources.list" dest="/etc/apt/sources.list"
```

Your sources.list could be like this

```
# Created by Ansible

deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
```

Let's set up some prerequisite packages

```
- name: update apt cache
  apt: update_cache=yes
  tags:
    - setup

- name: install curl
  apt: name=curl state=present
  tags:
    - setup

- name: install python-dev
  apt: name=python-dev state=present
  tags:
    - setup

- name: install pip
  apt: name=python-pip state=present
  tags:
    - setup

- name: update pip to latest version
  pip: name=pip state=latest
  tags:
    - setup

- name: setup ansible env
  setup:
  tags:
    - setup

- name: make sure pt-transport-https is installed
  apt: name=apt-transport-https state=installed
  tags:
    - setup
```

Then let's install Docker

```
- name: add docker server and host key
  apt_key: keyserver="hkp://p80.pool.sks-keyservers.net:80" id="58118E89F3A912897C070ADBF76221572C52609D" state=present

- name: add docker repo and update apt cache
  apt_repository: repo="deb https://apt.dockerproject.org/repo ubuntu-trusty main" update_cache=yes state=present

- name: install docker
  apt: name=docker-engine state=present

- name: install docker-py
  pip: name=docker-py version=1.1.0 state=present

- name: create deploy user (this is optional)
  user:
    name: "john"
    comment: "john"
    group: sudo
    password: "pa$$w0rd"
    generate_ssh_key: "yes"
    createhome: "yes"
    state: "present"

- name: set authorized key (this is optional)
  authorized_key:
    user: "john"
    key: "{{ lookup('file', '/path/to/your/id_rsa.pub') }}"
    state: "present"
```

OK, let's pull our docker image from Registry (AWS ECR, Docker Hub or Quay, etc.)

```
- name: login to ECR registry
  shell: "$(aws ecr get-login --region us-east-1)"

- name: pull Docker image from ECR
  shell: "docker pull your-hub.io/your-app:latest"
```

Run the image

```
- name: Up the version
  docker:
    image: "your-hub.io/your-app:latest"
    name: "your-app"
    state: reloaded
    expose: 5000
    port:
      - "80:5000"
```

That's it! Feel free to leave your comments below! :-)
