# dhall-zuul

This repository illustrates [dhall-lang](https://dhall-lang.org/) usage for Zuul configuration objects.

## Example

A default check pipeline is defined like so: [defaults.dhall](./defaults.dhall).
Then a config project can render it with custom connections like so: [examples/config.dhall](./examples/config.dhall).
The `config.dhall` evaluation result in:

```yaml
# dhall-to-yaml --explain --omitEmpty --file examples/config.dhall
- pipeline:
    description: The check pipeline
    manager: independent
    name: check
    require:
      pagure.io:
        merged: false
      review.rdoproject.org:
        current-patchset: false
        open: false
    trigger:
      pagure.io:
      - action: opened
        event: pg_pull_request
      review.rdoproject.org:
      - event: patchset-created
      - event: patchset-restored
```
