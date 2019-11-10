{- Zuul configuration types
-}

let Connection = ./types/connection.dhall

let ConnectionType = ./types/connections.dhall

let Pagure = ./types/pagure.dhall

let Gerrit = ./types/gerrit.dhall

let Pipeline = ./types/pipeline.dhall

in  { Pagure = Pagure
    , Gerrit = Gerrit
    , Connection = Connection
    , ConnectionType = ConnectionType
    , Pipeline = Pipeline
    }
