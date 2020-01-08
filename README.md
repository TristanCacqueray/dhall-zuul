# dhall-zuul

This repository contains [Zuul](https://zuul-ci.org) deployment object and dhall configuration.

## (WIP) Operator

Using [dhall-operator](https://github.com/TristanCacqueray/dhall-operator),
zuul application is defined [here](./operator/application/) and it can be deployed
with this CustomResource:

```yaml
apiVersion: softwarefactory-project.io/v1alpha1
kind: Zuul
metadata:
  name: simple-zuul
spec:
  connection:
    name: opendev.org
    driver: git
    params:
      baseurl: "https://opendev.org"
  projects:
    - zuul/zuul-base-jobs
    - zuul/zuul-jobs
```


## (WIP) Zuul type

Zuul objects are available as dhall type.

### Pipeline

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
