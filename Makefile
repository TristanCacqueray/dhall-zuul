build:
	operator-sdk build --image-builder podman quay.io/software-factory/zuul-operator:0.0.1

build-local:
	sudo ~/.local/bin/operator-sdk build --image-build-args "--root /var/lib/silverkube/storage --storage-driver vfs" --image-builder podman quay.io/software-factory/zuul-operator:0.0.1


# Generate demo deployments

playbook = @dhall-to-yaml --omit-empty --explain --output $(1) <<< '(env:DHALL_OPERATOR).Deploy.Ansible.Localhost ($(2))'
podman = @dhall-to-yaml --omit-empty --explain --output $(1) <<< '(env:DHALL_OPERATOR).Deploy.Podman.RenderCommands ($(2))'
k8s = @dhall-to-yaml --omit-empty --explain --output $(1) <<< '(env:DHALL_OPERATOR).Deploy.Kubernetes ($(2))'


ZUUL_DEMO = ./operator/application/Demo.dhall "SECRET_SSH_KEY" (Some "SECRET_KUBECONFIG") "demo01"

deployments/demo-playbook.yaml: operator/application/Demo.dhall
	$(call playbook,deployments/demo-playbook.yaml,$(ZUUL_DEMO))

deployments/demo-podman.sh: operator/application/Demo.dhall
	$(call podman,deployments/demo-podman.sh,$(ZUUL_DEMO))

deployments/demo-k8s.yaml: operator/application/Demo.dhall
	$(call k8s,deployments/demo-k8s.yaml,$(ZUUL_DEMO))

demo-app: deployments/demo-playbook.yaml deployments/demo-podman.sh deployments/demo-k8s.yaml


ZUUL_CR = (./operator/application/Zuul.dhall).Application ./deployments/cr-input.dhall

deployments/cr-playbook.yaml: operator/application/Zuul.dhall
	$(call playbook,deployments/cr-playbook.yaml,$(ZUUL_CR))

deployments/cr-podman.sh: operator/application/Zuul.dhall
	$(call podman,deployments/cr-podman.sh,$(ZUUL_CR))

deployments/cr-k8s.yaml: operator/application/Zuul.dhall
	$(call k8s,deployments/cr-k8s.yaml,$(ZUUL_CR))

cr-app: deployments/cr-playbook.yaml deployments/cr-podman.sh deployments/cr-k8s.yaml


deployments: demo-app cr-app



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
