{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let ConnectionFilter = { Gerrit : Bool, Pagure : Bool, Mqtt : Bool }

let ConnectionTriggers =
      { Gerrit = True, Pagure = True, Mqtt = False } : ConnectionFilter

let Get =
        λ(list : ConnectionFilter)
      → Prelude.List.filter
          types.Connection
          (λ(connection : types.Connection) → merge list connection.type)

let RenderPipelineTriggers =
        λ(config : types.Pipeline.TriggerConfig)
      → Prelude.List.map
          types.Connection
          types.Pipeline.TriggerRender
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue =
                  merge
                    (types.Pipeline.TriggerTransform connection config)
                    connection.type
              }
          )

let RenderPipelineRequires =
        λ(config : types.Pipeline.RequireConfig)
      → Prelude.List.map
          types.Connection
          types.Pipeline.RequireRender
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue =
                  merge
                    (types.Pipeline.RequireTransform connection config)
                    connection.type
              }
          )

let RenderPipeline =
        λ(pipeline : types.Pipeline.Config)
      → [ { pipeline =
              { name = pipeline.name
              , description = pipeline.description
              , precedence = pipeline.precedence
              , manager = merge types.Pipeline.ManagerValue pipeline.manager
              , require =
                  RenderPipelineRequires
                    pipeline.config.require
                    (Get ConnectionTriggers pipeline.connections)
              , trigger =
                  RenderPipelineTriggers
                    pipeline.config.trigger
                    (Get ConnectionTriggers pipeline.connections)
              }
          }
        ]

in  { Pipeline = RenderPipeline }
