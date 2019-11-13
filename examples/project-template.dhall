let zuul = ../package.dhall

let jobs = [ "linter", "tox" ]

in  zuul.render.ProjectTemplate
      { name = "my-template", pipelines = [ { name = "check", jobs = jobs } ] }
