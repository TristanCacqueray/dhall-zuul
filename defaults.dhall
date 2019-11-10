{- Default attributes
-}

let types = ./types.dhall

let PipelineCheck =
      { Type =
          types.Pipeline.Config
      , default =
          { name =
              "check"
          , description = Some "The check pipeline"
          , manager = types.Pipeline.Manager.Independent
          , config =
              { require =
                  { Gerrit = { open = Some True, current-patchset = Some True }
                  , Pagure = { merged = Some False }
                  }
              , trigger =
                  { Gerrit =
                      [ { event =
                            types.Gerrit.Event.patchset-created
                        , comment = None Text
                        }
                      , { event = types.Gerrit.Event.change-restored
                        , comment = None Text
                        }
                      , { event =
                            types.Gerrit.Event.comment-added
                        , comment =
                            Some
                              ''
                              (?i)^(Patch Set [0-9]+:)?( [\w\\+-]*)*(\n\n)?\s*(recheck|reverify)
                              ''
                        }
                      ]
                  , Pagure =
                      [ { event = "pg_pull_request", action = "opened" } ]
                  }
              }
          }
      }

in  { PipelineCheck = PipelineCheck }
