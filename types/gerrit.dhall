let ConnectionTypes = ./connections.dhall

let ConnectionType = ./connection.dhall

let Connection =
      { Type = ConnectionType
      , default = { type = ConnectionTypes.Gerrit, user = None Text }
      }

let ApprovalValue
    : Type
    = < Text : Optional Text | Integer : Integer | IntegerList : List Integer >

let Approval
    : Type
    = List { mapKey : Text, mapValue : ApprovalValue }

let ApprovalList
    : Type
    = List Approval

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

let TriggerValue
    : Type
    = { event : Event
      , comment : Optional Text
      , approval : Optional ApprovalList
      , require-approval : Optional ApprovalList
      }

let Trigger
    : Type
    = ConnectionType → List TriggerValue

let StatusValue
    : Type
    = { Verified : Natural }

let Status
    : Type
    = ConnectionType → StatusValue

in  { Connection = Connection
    , Event = Event
    , Approval = Approval
    , ApprovalList = ApprovalList
    , ApprovalValue = ApprovalValue
    , Require = Require
    , RequireValue = RequireValue
    , Trigger = Trigger
    , TriggerValue = TriggerValue
    , Status = Status
    , StatusValue = StatusValue
    }
