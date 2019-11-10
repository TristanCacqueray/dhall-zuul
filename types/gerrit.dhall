let ConnectionTypes = ./connections.dhall

let ConnectionType = ./connection.dhall

let Connection =
      { Type = ConnectionType
      , default = { type = ConnectionTypes.Gerrit, user = None Text }
      }

let Approval
    : Type
    = List { mapKey : Text, mapValue : Optional Text }

let RequireValue
    : Type
    = { open : Optional Bool
      , current-patchset : Optional Bool
      , approval : Optional Approval
      }

let Require
    : Type
    = ConnectionType → RequireValue

let Event
    : Type
    = < patchset-created | change-restored | comment-added >

let Trigger
    : Type
    = { event : Event, comment : Optional Text }

in  { Connection = Connection
    , Event = Event
    , Approval = Approval
    , Require = Require
    , RequireValue = RequireValue
    , Trigger = Trigger
    }
