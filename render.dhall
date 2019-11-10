{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let RenderPipelineTriggers =
        λ(config : types.Pipeline.TriggerConfig)
      → Prelude.List.map
          types.Connection
          types.Pipeline.TriggerRender
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue =
                  merge (types.Pipeline.TriggerTransform config) connection.type
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
                  merge (types.Pipeline.RequireTransform config) connection.type
              }
          )

let RenderPipeline =
        λ(pipeline : types.Pipeline.Config)
      → [ { pipeline =
              { name = pipeline.name
              , description = pipeline.description
              , manager = merge types.Pipeline.ManagerValue pipeline.manager
              , require =
                  RenderPipelineRequires
                    pipeline.config.require
                    pipeline.connections
              , trigger =
                  RenderPipelineTriggers
                    pipeline.config.trigger
                    pipeline.connections
              }
          }
        ]

in  { Pipeline = RenderPipeline }
