#!/bin/bash -ex
podman pod create --name zuul    --publish 9000:9000 
# Volume zuul
podman volume create zuul-zuul || true
VOLPATH=$(podman volume inspect zuul-zuul --format '{{.Mountpoint}}')
mkdir -p $VOLPATH/$(dirname zuul.conf)
cat << EOF > $VOLPATH/zuul.conf
[gearman]
server=scheduler

[gearman_server]
start=true

[zookeeper]
hosts=zk

[merger]
git_user_email=zuul@localhost
git_user_name=Zuul

[scheduler]
tenant_config=/etc/zuul-scheduler/main.yaml

[web]
listen_address=0.0.0.0
root=http://web:9000

[executor]
private_key_file=/etc/zuul-executor/id_rsa
manage_ansible=false

[connection "sql"]
driver=sql
dburi=postgresql://zuul:super-secret@db/zuul

[connection opendev.org]
driver=git
baseurl=https://opendev.org

[connection review.rdoproject.org]
driver=gerrit
server=review.rdoproject.org
sshkey=/etc/zuul-gerrit-review.rdoproject.org/id_rsa
user=zuul
baseurl=https://review.rdoproject.org/r/

EOF

# Volume nodepool
podman volume create zuul-nodepool || true
VOLPATH=$(podman volume inspect zuul-nodepool --format '{{.Mountpoint}}')
mkdir -p $VOLPATH/$(dirname nodepool.yaml)
cat << EOF > $VOLPATH/nodepool.yaml
zookeeper-servers:
  - host: zk
    port: 2181
webapp:
  port: 5000


EOF

podman run --pod zuul --name zuul-dns --detach --add-host=db:127.0.0.1 --add-host=zk:127.0.0.1 --add-host=launcher:127.0.0.1 --add-host=executor:127.0.0.1 --add-host=web:127.0.0.1 --add-host=scheduler:127.0.0.1 registry.fedoraproject.org/fedora:31 sleep infinity
podman run --pod zuul --name zuul-db --detach --env=POSTGRES_PASSWORD='super-secret' --env=POSTGRES_USER='zuul' --rm docker.io/library/postgres:12.1
podman run --pod zuul --name zuul-zk --detach --rm quay.io/software-factory/zookeeper:3.4
podman run --pod zuul --name zuul-launcher --detach --volume=zuul-nodepool:/etc/nodepool --volume=nodepool-yaml-conf:/etc/nodepool-user --volume=kube-config:/etc/nodepool-kubernetes --env=KUBECONFIG='/etc/nodepool-kubenertes/kube.config' --env=OS_CLIENT_CONFIG_FILE='/etc/nodepool-openstack/undefined' --rm quay.io/software-factory/nodepool-launcher:3.4 "sh" "-c" "cat /etc/nodepool/nodepool.yaml /etc/nodepool-user/nodepool.yaml > ~/nodepool.yaml ; nodepool-launcher -d -c ~/nodepool.yaml"
podman run --pod zuul --name zuul-executor --privileged --volume=zuul-zuul:/etc/zuul --volume=executor-ssh-key:/etc/zuul-executor --volume=rdo-key:/etc/zuul-gerrit-review.rdoproject.org --volume=github:/etc/zuul-github-github.com --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod zuul --name zuul-executor --privileged --detach --volume=zuul-zuul:/etc/zuul --volume=executor-ssh-key:/etc/zuul-executor --volume=rdo-key:/etc/zuul-gerrit-review.rdoproject.org --volume=github:/etc/zuul-github-github.com --rm quay.io/software-factory/zuul-executor:3.4 "zuul-executor" "-d"
podman run --pod zuul --name zuul-web --volume=zuul-zuul:/etc/zuul --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod zuul --name zuul-web --detach --volume=zuul-zuul:/etc/zuul --rm quay.io/software-factory/zuul-web:3.4 "zuul-web" "-d"
podman run --pod zuul --name zuul-scheduler --detach --volume=zuul-zuul:/etc/zuul --volume=zuul-yaml-conf:/etc/zuul-scheduler --volume=rdo-key:/etc/zuul-gerrit-review.rdoproject.org --volume=github:/etc/zuul-github-github.com --rm quay.io/software-factory/zuul-scheduler:3.4 "zuul-scheduler" "-d"
podman pod start zuul
echo 'Press enter to stop'
read
set +x
podman pod kill zuul
podman pod rm -f zuul
podman volume rm -af
