podman volume create executor-ssh-key || true
VOLPATH=$(podman volume inspect executor-ssh-key --format '{{ .Mountpoint }}')
cat ~/.ssh/id_rsa > $VOLPATH/id_rsa

podman volume create zuul-yaml-conf || true
VOLPATH=$(podman volume inspect zuul-yaml-conf --format '{{ .Mountpoint }}')
cat ~/.ssh/id_rsa > $VOLPATH/main.yaml <<EOF
- tenant:
    name: local
    sources: []
EOF
