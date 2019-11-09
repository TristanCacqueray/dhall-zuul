{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let RenderPipelineTriggers =
        λ(config : types.PipelineConfigTrigger)
      → Prelude.List.map
          types.Connection
          types.PipelineRenderTrigger
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue = merge config connection.type
              }
          )

let RenderPipelineRequires =
        λ(config : types.PipelineConfigRequire)
      → Prelude.List.map
          types.Connection
          types.PipelineRenderRequire
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue = merge config connection.type
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
