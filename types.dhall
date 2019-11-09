{- Zuul configuration types
-}

let ConnectionType
    : Type
    = < Gerrit | Pagure | GitHub >

let Connection
    : Type
    = { name : Text, type : ConnectionType }

let Pipeline
    : Type
    = { name : Text
      , description : Optional Text
      , connections : List Connection
      }

in  { ConnectionType = ConnectionType
    , Connection = Connection
    , Pipeline = Pipeline
    }
