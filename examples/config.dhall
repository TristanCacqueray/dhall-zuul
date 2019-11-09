{- This file demonstrate a config project configuration
-}

let defaults = ../defaults.dhall

let types = ../types.dhall

let render = ../render.dhall

let connection =
      { name = "review.rdoproject.org", type = types.ConnectionType.Gerrit }

let pipeline = { name = "check", connections = [ connection ] }

in  render.Pipeline (defaults.Pipeline ⫽ pipeline)
