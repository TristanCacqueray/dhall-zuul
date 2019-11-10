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
    failure:
      mqtt:
        topic: zuul/{pipeline}/result/{project}/{branch}
      pagure.io:
        comment: true
        status: failure
      review.rdoproject.org:
        Verified: -1
    manager: independent
    name: check
    precedence: low
    require:
      pagure.io:
        merged: false
      review.rdoproject.org:
        current-patchset: true
        open: true
    start:
      mqtt:
        topic: zuul/{pipeline}/start/{project}/{branch}
      pagure.io:
        comment: false
        status: pending
      review.rdoproject.org:
        Verified: 0
    success:
      mqtt:
        topic: zuul/{pipeline}/result/{project}/{branch}
      pagure.io:
        comment: true
        status: success
      review.rdoproject.org:
        Verified: 1
    trigger:
      pagure.io:
      - action: opened
        event: pg_pull_request
      review.rdoproject.org:
      - event: patchset-created
      - event: change-restored
      - comment: |
          (?i)^(Patch Set [0-9]+:)?( [\w\\+-]*)*(\n\n)?\s*(recheck|reverify)
        event: comment-added
      - approval:
        - Workflow: 1
        event: comment-added
        require-approval:
        - Verified:
          - -1
          - -2
          username: zuul
```
