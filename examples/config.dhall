{- This file demonstrate a config project configuration

-}

let zuul = ../package.dhall

let connections =
      [ zuul.types.Pagure.Connection::{ name = "pagure.io" }
      , zuul.types.Gerrit.Connection::{
        , name = "review.rdoproject.org"
        , user = Some "zuul"
        }
      ]

in  zuul.render.Pipeline
      zuul.defaults.PipelineCheck::{ connections = connections }
