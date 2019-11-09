{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let RenderPipelineTrigger =
        λ(connection : types.Connection)
      → { mapKey = connection.name
        , mapValue =
            merge
              { Gerrit = [ { event = "patchst-created" } ]
              , GitHub = [ { event = "pull-request" } ]
              , Pagure = [ { event = "pg_pull_request" } ]
              }
              connection.type
        }

let RenderPipelineTriggers =
      Prelude.List.map
        types.Connection
        types.ConnectionTrigger
        RenderPipelineTrigger

let RenderPipeline =
        λ(pipeline : types.Pipeline)
      → [ { pipeline =
              { name = pipeline.name
              , description = pipeline.description
              , trigger = RenderPipelineTriggers pipeline.connections
              }
          }
        ]

in  { Pipeline = RenderPipeline }
