install:
	kubectl apply -f operator/deploy/crd.yaml -f operator/deploy/operator.yaml

build:
	operator-sdk build --image-builder podman quay.io/software-factory/zuul-operator:0.0.1

build-local:
	sudo ~/.local/bin/operator-sdk build --image-build-args "--root /var/lib/silverkube/storage --storage-driver vfs" --image-builder podman quay.io/software-factory/zuul-operator:0.0.1


# Generate demo deployments

playbook = @dhall-to-yaml --omit-empty --explain --output $(1) <<< '(env:DHALL_OPERATOR).Deploy.Ansible.Localhost ($(2))'
podman = @dhall text --explain > $(1) <<< '(env:DHALL_OPERATOR).Deploy.Podman.RenderCommands ($(2))'
k8s = @dhall-to-yaml --omit-empty --explain --output $(1) <<< '(env:DHALL_OPERATOR).Deploy.Kubernetes ($(2))'


ZUUL_DEMO = ./operator/application/Demo.dhall "SECRET_SSH_KEY" (Some "SECRET_KUBECONFIG") "demo01"

demo-playbook:
	$(call playbook,deployments/demo-playbook.yaml,$(ZUUL_DEMO))

demo-podman:
	$(call podman,deployments/demo-podman.sh,$(ZUUL_DEMO))

demo-k8s:
	$(call k8s,deployments/demo-k8s.yaml,$(ZUUL_DEMO))

demo-app: demo-playbook demo-podman demo-k8s


ZUUL_CR = (./operator/application/Zuul.dhall).Application ./deployments/cr-input.dhall

cr-playbook:
	$(call playbook,deployments/cr-playbook.yaml,$(ZUUL_CR))

cr-podman:
	$(call podman,deployments/cr-podman.sh,$(ZUUL_CR))

cr-k8s:
	$(call k8s,deployments/cr-k8s.yaml,$(ZUUL_CR))

cr-app: cr-playbook cr-podman cr-k8s


deployments: demo-app cr-app
	@sh -c "chmod +x deployments/*.sh"


doc:
	@(python3 -c "'Poor man autodoc generator' \
'# Get README.d indexes'; \
doc = open('README.md').read().split('\n'); \
blockstart = doc.index('\`\`\`yaml'); \
blockend = doc.index('\`\`\`'); \
'# Generate example'; \
import subprocess; \
dat = subprocess.check_output(['dhall-to-yaml', '--omitEmpty', '--file', 'examples/config.dhall']).decode('utf-8'); \
newdoc = doc[:blockstart + 2] + dat.split('\n')[:-1] + doc[blockend:]; \
exit(0) if newdoc == doc else open('README.md', 'w').write('\n'.join(newdoc)); print('README.md updated!');")
