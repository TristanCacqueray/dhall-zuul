{- Zuul configuration types
-}

let Connection = ./types/connection.dhall

let ConnectionType = ./types/connections.dhall

let Pagure = ./types/pagure.dhall

let Gerrit = ./types/gerrit.dhall

let Mqtt = ./types/mqtt.dhall

let Pipeline = ./types/pipeline.dhall

let Project = ./types/project.dhall

in  { Pagure = Pagure
    , Gerrit = Gerrit
    , Mqtt = Mqtt
    , Connection = Connection
    , ConnectionType = ConnectionType
    , Pipeline = Pipeline
    , Project = Project
    }
