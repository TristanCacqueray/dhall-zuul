{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let RenderConnectionConfig =
        λ(configType : Type)
      → λ(pipelineType : Type)
      → λ(transformer : configType → pipelineType)
      → λ(config : configType)
      → Prelude.List.map
          types.Connection
          pipelineType
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue = merge (transformer config) connection.type
              }
          )

let RenderPipeline =
        λ(pipeline : types.Pipeline)
      → [ { pipeline =
              { name = pipeline.name
              , description = pipeline.description
              , require =
                  RenderConnectionConfig
                    types.PipelineRequireConfig
                    types.PipelineRequireRender
                    types.PipelineRequireTransform
                    pipeline.config.require
                    pipeline.connections
              , trigger =
                  RenderConnectionConfig
                    types.PipelineTriggerConfig
                    types.PipelineTriggerRender
                    types.PipelineTriggerTransform
                    pipeline.config.trigger
                    pipeline.connections
              }
          }
        ]

in  { Pipeline = RenderPipeline }
