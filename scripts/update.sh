#!/bin/sh -ex

echo "Remove previous operator"
kubectl delete -f operator/deploy/operator.yaml || :

echo "Update local cri-o image"
CTX=$(sudo buildah from --root /var/lib/silverkube/storage --storage-driver vfs quay.io/software-factory/zuul-operator:0.0.1)
MNT=$(sudo buildah mount  --root /var/lib/silverkube/storage --storage-driver vfs $CTX)

sudo rsync -avi operator/roles/ ${MNT}/opt/ansible/roles/
sudo rsync -avi operator/application/ ${MNT}/opt/ansible/dhall/applications/zuul/

# sudo buildah --root /var/lib/silverkube/storage --storage-driver vfs umount $MNT
sudo buildah commit --root /var/lib/silverkube/storage --storage-driver vfs --rm ${CTX} quay.io/software-factory/zuul-operator:0.0.1

kubectl apply -f operator/deploy/operator.yaml
