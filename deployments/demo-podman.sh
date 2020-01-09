|
#!/bin/bash -ex
podman pod create --name demo01      --publish 9000:9000
# Volume zuul
podman volume create demo01-zuul || true
VOLPATH=$(podman volume inspect demo01-zuul --format '{{.Mountpoint}}')
mkdir -p $VOLPATH/$(dirname zuul.conf)
cat << EOF > $VOLPATH/zuul.conf
[gearman]
server=scheduler

[gearman_server]
start=true

[zookeeper]
hosts=zk

[scheduler]
tenant_config=/etc/zuul/main.yaml

[web]
listen_address=0.0.0.0

[executor]
private_key_file=/etc/zuul/id_rsa

[connection "sql"]
driver=sql
dburi=postgresql://zuul:secret@db/zuul

[connection "local-git"]
driver=git
baseurl=git://config/
EOF
mkdir -p $VOLPATH/$(dirname main.yaml)
cat << EOF > $VOLPATH/main.yaml
- tenant:
    name: local
    source:
      local-git:
        config-projects:
          - config
EOF
mkdir -p $VOLPATH/$(dirname id_rsa)
cat << EOF > $VOLPATH/id_rsa
SECRET_SSH_KEYEOF

# Volume config
podman volume create demo01-config || true
VOLPATH=$(podman volume inspect demo01-config --format '{{.Mountpoint}}')
mkdir -p $VOLPATH/$(dirname zuul.yaml)
cat << EOF > $VOLPATH/zuul.yaml
- pipeline:
    name: periodic
    manager: independent
    trigger:
      timer:
        - time: '* * * * * *'
    success:
      sql:
    failure:
      sql:

- nodeset:
    name: localhost
    nodes: []

- nodeset:
    name: centos-pod
    nodes:
      - name: centos-pod
        label: pod-centos

- job:
    name: base
    parent: null
    run: base.yaml
    nodeset: centos-pod

- job:
    name: test-job

- project:
    periodic:
      jobs:
        - test-job
EOF
mkdir -p $VOLPATH/$(dirname base.yaml)
cat << EOF > $VOLPATH/base.yaml
- hosts: all
  tasks:
    - debug: msg='Demo job is running'
    - pause: seconds=30
EOF

# Volume nodepool
podman volume create demo01-nodepool || true
VOLPATH=$(podman volume inspect demo01-nodepool --format '{{.Mountpoint}}')
mkdir -p $VOLPATH/$(dirname nodepool.yaml)
cat << EOF > $VOLPATH/nodepool.yaml
zookeeper-servers:
  - host: zk
    port: 2181
webapp:
  port: 5000

labels:
  - name: pod-centos
providers:
  - name: kube-cluster
    driver: openshiftpods
    context: local
    max-pods: 4
    pools:
    - name: default
      labels:
        - name: pod-centos
          image: quay.io/software-factory/pod-centos-7
          python-path: /bin/python2
EOF
mkdir -p $VOLPATH/$(dirname kube.config)
cat << EOF > $VOLPATH/kube.config
SECRET_KUBECONFIGEOF

podman run --pod demo01 --name demo01-dns --detach --add-host=config:127.0.0.1 --add-host=zk:127.0.0.1 --add-host=db:127.0.0.1 --add-host=scheduler:127.0.0.1 --add-host=executor:127.0.0.1 --add-host=web:127.0.0.1 --add-host=launcher:127.0.0.1 registry.fedoraproject.org/fedora:31 sleep infinity
podman run --pod demo01 --name demo01-config --detach --volume=demo01-config:/config --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "mkdir -p /git/config; cp /config/* /git/config;cd /git/config ;git config --global user.email zuul@localhost ;git config --global user.name Zuul ;git init . ;git add -A . ;git commit -m init ;git daemon --export-all --reuseaddr --verbose --base-path=/git/ /git/"
podman run --pod demo01 --name demo01-zk --detach --rm quay.io/software-factory/zookeeper:3.4
podman run --pod demo01 --name demo01-db --detach --env=POSTGRES_PASSWORD='secret' --env=POSTGRES_USER='zuul' --rm docker.io/library/postgres:12.1
podman run --pod demo01 --name demo01-scheduler --volume=demo01-zuul:/etc/zuul --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 5432))' db 2>/dev/null; do echo 'waiting for db:5432'; sleep 1; done"
podman run --pod demo01 --name demo01-scheduler --detach --volume=demo01-zuul:/etc/zuul --rm quay.io/software-factory/zuul-scheduler:3.4 "zuul-scheduler" "-d"
podman run --pod demo01 --name demo01-executor --privileged --volume=demo01-zuul:/etc/zuul --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod demo01 --name demo01-executor --privileged --detach --volume=demo01-zuul:/etc/zuul --rm quay.io/software-factory/zuul-executor:3.4 "zuul-executor" "-d"
podman run --pod demo01 --name demo01-web --volume=demo01-zuul:/etc/zuul --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod demo01 --name demo01-web --detach --volume=demo01-zuul:/etc/zuul --rm quay.io/software-factory/zuul-web:3.4 "zuul-web" "-d"
podman run --pod demo01 --name demo01-launcher --detach --volume=demo01-nodepool:/etc/nodepool --env=KUBECONFIG='/etc/nodepool/kube.config' --env=OS_CLIENT_CONFIG_FILE='/etc/nodepool/clouds.yaml' --rm quay.io/software-factory/nodepool-launcher:3.4 "nodepool-launcher" "-d"
podman pod start demo01
echo 'Press enter to stop'
read
set +x
podman pod kill demo01
podman pod rm -f demo01
podman volume rm -af
