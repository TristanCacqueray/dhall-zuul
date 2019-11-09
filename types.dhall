{- Zuul configuration types
-}

let ConnectionType
    : Type
    = < Gerrit | Pagure | GitHub >

let Connection
    : Type
    = { name : Text, type : ConnectionType }

let ConnectionTriggerEvent
    : Type
    = { event : Text }

let ConnectionTrigger
    : Type
    = { mapKey : Text, mapValue : List ConnectionTriggerEvent }

let Pipeline
    : Type
    = { name : Text
      , description : Optional Text
      , connections : List Connection
      }

in  { ConnectionType = ConnectionType
    , ConnectionTrigger = ConnectionTrigger
    , Connection = Connection
    , Pipeline = Pipeline
    }
