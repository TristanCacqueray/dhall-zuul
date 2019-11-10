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
          , precedence = types.Pipeline.Precedence.low
          , manager = types.Pipeline.Manager.Independent
          , config =
              { require =
                  { Gerrit =
                        λ(connection : types.Connection)
                      → { open = Some True
                        , current-patchset = Some True
                        , approval = None types.Gerrit.Approval
                        }
                  , Pagure = { merged = Some False }
                  }
              , trigger =
                  { Gerrit =
                        λ ( connection
                          : types.Connection
                          )
                      → [ { event =
                              types.Gerrit.Event.patchset-created
                          , comment = None Text
                          , approval = None types.Gerrit.ApprovalList
                          , require-approval = None types.Gerrit.ApprovalList
                          }
                        , { event = types.Gerrit.Event.change-restored
                          , comment = None Text
                          , approval = None types.Gerrit.ApprovalList
                          , require-approval = None types.Gerrit.ApprovalList
                          }
                        , { event =
                              types.Gerrit.Event.comment-added
                          , comment =
                              Some
                                ''
                                (?i)^(Patch Set [0-9]+:)?( [\w\\+-]*)*(\n\n)?\s*(recheck|reverify)
                                ''
                          , approval = None types.Gerrit.ApprovalList
                          , require-approval = None types.Gerrit.ApprovalList
                          }
                        , { event = types.Gerrit.Event.comment-added
                          , comment = None Text
                          , approval =
                              Some
                                [ toMap
                                    { Workflow =
                                        types.Gerrit.ApprovalValue.Integer +1
                                    }
                                ]
                          , require-approval =
                              Some
                                [ toMap
                                    { Verified =
                                        types.Gerrit.ApprovalValue.IntegerList
                                          [ -1, -2 ]
                                    , username =
                                        types.Gerrit.ApprovalValue.Text
                                          connection.user
                                    }
                                ]
                          }
                        ]
                  , Pagure =
                      [ { event = "pg_pull_request", action = "opened" } ]
                  }
              }
          }
      }

in  { PipelineCheck = PipelineCheck }
