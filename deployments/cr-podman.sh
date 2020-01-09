|
#!/bin/bash -ex
podman pod create --name zuul 
# Volume zuul
podman volume create zuul-zuul || true
VOLPATH=$(podman volume inspect zuul-zuul --format '{{.Mountpoint}}')
mkdir -p $VOLPATH/$(dirname zuul.conf)
cat << EOF > $VOLPATH/zuul.conf
[gearman]
server=scheduler

[zookeeper]
hosts=zk

[merger]
git_user_email=zuul@zuul

[gearman_server]
start=true

[scheduler]
tenant_config=/etc/zuul/main.yaml

[web]
listen_address=0.0.0.0

[executor]
private_key_file=/etc/zuul-executor/id_rsa

EOF

podman run --pod zuul --name zuul-dns --detach --add-host=executor:127.0.0.1 registry.fedoraproject.org/fedora:31 sleep infinity
podman run --pod zuul --name zuul-executor --privileged --volume=zuul-zuul:/etc/zuul --volume=executor-ssh-key-secret-name:/etc/zuul-executor --rm quay.io/software-factory/zuul:3.4 "sh" "-c" "until python -c 'import socket, sys; socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((sys.argv[1], 4730))' scheduler 2>/dev/null; do echo 'waiting for scheduler:4730'; sleep 1; done"
podman run --pod zuul --name zuul-executor --privileged --detach --volume=zuul-zuul:/etc/zuul --volume=executor-ssh-key-secret-name:/etc/zuul-executor --rm quay.io/software-factory/zuul-executor:3.4 "zuul-executor" "-d"
podman pod start zuul
echo 'Press enter to stop'
read
set +x
podman pod kill zuul
podman pod rm -f zuul
podman volume rm -af
