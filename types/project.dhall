let JobVars
    : Type
    = { vars : List Text }

let Jobs
    : Type
    = Text

let Pipeline
    : Type
    = { name : Text, jobs : List Jobs }

let Template
    : Type
    = { name : Text, pipelines : List Pipeline }

in  { Pipeline = Pipeline, JobVars = JobVars, Jobs = Jobs, Template = Template }
