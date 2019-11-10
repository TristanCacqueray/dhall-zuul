let ConnectionTypes = ./connections.dhall

let ConnectionType = ./connection.dhall

let Connection =
      { Type = ConnectionType, default = { type = ConnectionTypes.Gerrit } }

let Require
    : Type
    = { open : Optional Bool, current-patchset : Optional Bool }

let Event
    : Type
    = < patchset-created | change-restored | comment-added >

let Trigger
    : Type
    = { event : Event, comment : Optional Text }

in  { Connection = Connection
    , Event = Event
    , Require = Require
    , Trigger = Trigger
    }
