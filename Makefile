build:
	operator-sdk build --image-builder podman quay.io/software-factory/zuul-operator:0.0.1

build-local:
	sudo ~/.local/bin/operator-sdk build --image-build-args "--root /var/lib/silverkube/storage --storage-driver vfs" --image-builder podman quay.io/software-factory/zuul-operator:0.0.1

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
