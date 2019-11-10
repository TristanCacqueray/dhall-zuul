{- Default attributes
-}

let types = ./types.dhall

let PipelineCheck =
      { Type = types.Pipeline.Config
      , default =
          { name = "check"
          , description = Some "The check pipeline"
          , manager = types.Pipeline.Manager.Independent
          , config =
              { require =
                  { Gerrit =
                      { open = Some False, current-patchset = Some False }
                  , Pagure = { merged = Some False }
                  }
              , trigger =
                  { Gerrit =
                      [ { event = "patchset-created" }
                      , { event = "patchset-restored" }
                      ]
                  , Pagure =
                      [ { event = "pg_pull_request", action = "opened" } ]
                  }
              }
          }
      }

in  { PipelineCheck = PipelineCheck }
