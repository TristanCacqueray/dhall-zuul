let ConnectionTypes = ./connections.dhall

let ConnectionType = ./connection.dhall

let Connection =
      { Type = ConnectionType, default = { type = ConnectionTypes.Pagure } }

let Require
    : Type
    = { open : Optional Bool, current-patchset : Optional Bool }

let Trigger
    : Type
    = { event : Text }

in  { Connection = Connection, Require = Require, Trigger = Trigger }
