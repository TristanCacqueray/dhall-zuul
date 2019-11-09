{- Methods to generate Zuul configuration
-}

let types = ./types.dhall

let RenderPipeline =
        λ(pipeline : types.Pipeline)
      → [ { pipeline =
              { name = pipeline.name, description = pipeline.description }
          }
        ]

in  { Pipeline = RenderPipeline }
