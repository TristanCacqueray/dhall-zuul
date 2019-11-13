{- Methods to generate Zuul configuration
-}

let Prelude = ./Prelude.dhall

let types = ./types.dhall

let ConnectionFilter = { Gerrit : Bool, Pagure : Bool, Mqtt : Bool }

let ConnectionTriggers =
      { Gerrit = True, Pagure = True, Mqtt = False } : ConnectionFilter

let ConnectionReporters =
      { Gerrit = True, Pagure = True, Mqtt = True } : ConnectionFilter

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

let RenderPipelineStatus =
        λ(config : types.Pipeline.StatusConfig)
      → Prelude.List.map
          types.Connection
          types.Pipeline.StatusRender
          (   λ(connection : types.Connection)
            → { mapKey = connection.name
              , mapValue =
                  merge
                    (types.Pipeline.StatusTransform connection config)
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
              , start =
                  RenderPipelineStatus
                    pipeline.config.start
                    (Get ConnectionReporters pipeline.connections)
              , success =
                  RenderPipelineStatus
                    pipeline.config.success
                    (Get ConnectionReporters pipeline.connections)
              , failure =
                  RenderPipelineStatus
                    pipeline.config.failure
                    (Get ConnectionReporters pipeline.connections)
              }
          }
        ]

let RenderProjectTemplate =
        λ(template : types.Project.Template)
      → let TemplateKeyValue
            : Type
            = < name : Text | pipeline : { jobs : List types.Project.Jobs } >

        in  [ { project-template =
                    [ { mapKey = "name"
                      , mapValue = TemplateKeyValue.name template.name
                      }
                    ]
                  # Prelude.List.map
                      types.Project.Pipeline
                      { mapKey : Text, mapValue : TemplateKeyValue }
                      (   λ(pipeline : types.Project.Pipeline)
                        → { mapKey = pipeline.name
                          , mapValue =
                              TemplateKeyValue.pipeline { jobs = pipeline.jobs }
                          }
                      )
                      template.pipelines
              }
            ]

in  { Pipeline = RenderPipeline, ProjectTemplate = RenderProjectTemplate }
