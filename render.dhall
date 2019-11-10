{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let RenderPipelineTriggers =
        λ(config : types.PipelineTriggerConfig)
      → Prelude.List.map
          types.Connection
          types.PipelineTriggerRender
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue =
                  merge (types.PipelineTriggerTransform config) connection.type
              }
          )

let RenderPipelineRequires =
        λ(config : types.PipelineRequireConfig)
      → Prelude.List.map
          types.Connection
          types.PipelineRequireRender
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue =
                  merge (types.PipelineRequireTranform config) connection.type
              }
          )

let RenderPipeline =
        λ(pipeline : types.Pipeline)
      → [ { pipeline =
              { name = pipeline.name
              , description = pipeline.description
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
