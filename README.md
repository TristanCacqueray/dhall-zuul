# dhall-zuul

This repository illustrates [dhall-lang](https://dhall-lang.org/) usage for Zuul configuration objects.

## Example

A config project configuration file: [./examples/config.dhall](./examples/config.dhall) results in:

```yaml
# dhall-to-yaml --explain --omitEmpty --file examples/config.dhall
- pipeline:
    name: check
    trigger:
      review.rdoproject.org:
      - event: patchst-created
```
