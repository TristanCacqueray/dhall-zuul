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
