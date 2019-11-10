let ConnectionTypes = ./connections.dhall

let ConnectionType = ./connection.dhall

let Connection =
      { Type = ConnectionType
      , default = { type = ConnectionTypes.Pagure, user = None Text }
      }

let Require
    : Type
    = { merged : Optional Bool }

let Trigger
    : Type
    = { event : Text, action : Text }

let Status
    : Type
    = { status : Text, comment : Bool }

in  { Connection = Connection
    , Require = Require
    , Trigger = Trigger
    , Status = Status
    }
