{- Default attributes
-}

let types = ./types.dhall

let PipelineCheck =
      { Type = types.Pipeline
      , default =
          { name = "check"
          , description = Some "The check pipeline"
          , config =
              { require =
                  { Gerrit =
                      types.ConnectionRequireValue.Gerrit
                        { open = Some False, current-patchset = Some False }
                  , Pagure =
                      types.ConnectionRequireValue.Pagure
                        { merged = Some False }
                  }
              , trigger =
                  { Gerrit =
                      types.ConnectionTriggerValue.Gerrit
                        [ { event = "patchset-created" }
                        , { event = "patchset-restored" }
                        ]
                  , Pagure =
                      types.ConnectionTriggerValue.Pagure
                        [ { event = "pg_pull_request", action = "opened" } ]
                  }
              }
          }
      }

in  { PipelineCheck = PipelineCheck }
