{- This file demonstrate a config project configuration

-}

let zuul = ../package.dhall

let connections =
      [ { name = "pagure.io", type = zuul.types.ConnectionType.Pagure }
      , { name = "review.rdoproject.org"
        , type = zuul.types.ConnectionType.Gerrit
        }
      ]

in  zuul.render.Pipeline
      zuul.defaults.PipelineCheck::{ connections = connections }
