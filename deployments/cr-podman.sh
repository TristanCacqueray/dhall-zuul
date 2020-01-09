#!/bin/bash -ex
podman pod create --name zuul  --publish 9000:9000 
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


EOF

podman run --pod zuul --name zuul-dns --detach --add-host=executor:127.0.0.1 --add-host=web:127.0.0.1 --add-host=scheduler:127.0.0.1 registry.fedoraproject.org/fedora:31 sleep infinity
podman run --pod zuul --name zuul-executor --privileged --volume=zuul-zuul:/etc/zuul --volume=executor-ssh-key:/etc/zuul-executor --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod zuul --name zuul-executor --privileged --detach --volume=zuul-zuul:/etc/zuul --volume=executor-ssh-key:/etc/zuul-executor --rm quay.io/software-factory/zuul-executor:3.4 "zuul-executor" "-d"
podman run --pod zuul --name zuul-web --volume=zuul-zuul:/etc/zuul --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod zuul --name zuul-web --detach --volume=zuul-zuul:/etc/zuul --rm quay.io/software-factory/zuul-web:3.4 "zuul-web" "-d"
podman run --pod zuul --name zuul-scheduler --detach --volume=zuul-zuul:/etc/zuul --volume=zuul-yaml-conf:/etc/zuul-scheduler --rm quay.io/software-factory/zuul-scheduler:3.4 "zuul-scheduler" "-d"
podman pod start zuul
echo 'Press enter to stop'
read
set +x
podman pod kill zuul
podman pod rm -f zuul
podman volume rm -af
