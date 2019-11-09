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
              }
          }
      }

in  { PipelineCheck = PipelineCheck }
