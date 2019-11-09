{- This file demonstrate a config project configuration

-}

let types = ../types.dhall

let defaults = ../defaults.dhall

let render = ../render.dhall

let connections =
      [ { name = "pagure.io", type = types.ConnectionType.Pagure }
      , { name = "review.rdoproject.org", type = types.ConnectionType.Gerrit }
      ]

let checkPipeline = defaults.PipelineCheck::{ connections = connections }

in  render.Pipeline checkPipeline
