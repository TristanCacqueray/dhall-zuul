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
    = { name : Text }

in  { Connection = Connection, Pipeline = Pipeline }
