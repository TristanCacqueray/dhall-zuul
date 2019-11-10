let ConnectionTypes = ./connections.dhall

let ConnectionType = ./connection.dhall

let Connection =
      { Type = ConnectionType
      , default = { type = ConnectionTypes.Mqtt, user = None Text }
      }

let Status
    : Type
    = { topic : Text }

in  { Connection = Connection, Status = Status }
