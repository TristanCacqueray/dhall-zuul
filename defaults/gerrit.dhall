let Gerrit = ../types/gerrit.dhall

let Trigger =
      { Type = Gerrit.TriggerValue
      , default =
          { comment = None Text
          , approval = None Gerrit.ApprovalList
          , require-approval = None Gerrit.ApprovalList
          }
      }

let Workflow =
        λ(value : Integer)
      → toMap { Workflow = Gerrit.ApprovalValue.Integer value }

let Verified =
        λ(value : List Integer)
      → toMap { Verified = Gerrit.ApprovalValue.IntegerList value }

let Username =
        λ(value : Optional Text)
      → toMap { username = Gerrit.ApprovalValue.Text value }

in  { Trigger = Trigger
    , Approval =
        { Workflow = Workflow, Verified = Verified, Username = Username }
    }
