let Connection = ./connection.dhall

let Pagure = ./pagure.dhall

let Gerrit = ./gerrit.dhall

let RequireConfig
    : Type
    = { Gerrit : Gerrit.Require, Pagure : Pagure.Require }

let RequireValue
    : Type
    = < Gerrit : Gerrit.RequireValue | Pagure : Pagure.Require >

let RequireTransform =
        λ(connection : Connection)
      → λ(config : RequireConfig)
      → { Gerrit = RequireValue.Gerrit (config.Gerrit connection)
        , Pagure = RequireValue.Pagure config.Pagure
        }

let RequireRender
    : Type
    = { mapKey : Text, mapValue : RequireValue }

let TriggerConfig
    : Type
    = { Gerrit : Gerrit.Trigger, Pagure : List Pagure.Trigger }

let TriggerValue
    : Type
    = < Gerrit : List Gerrit.TriggerValue | Pagure : List Pagure.Trigger >

let TriggerTransform =
        λ(connection : Connection)
      → λ(config : TriggerConfig)
      → { Gerrit = TriggerValue.Gerrit (config.Gerrit connection)
        , Pagure = TriggerValue.Pagure config.Pagure
        }

let TriggerRender
    : Type
    = { mapKey : Text, mapValue : TriggerValue }

let Manager
    : Type
    = < Independent | Dependent >

let Precedence
    : Type
    = < low | high >

let ManagerValue = { Independent = "independent", Dependent = "dependent" }

let Config
    : Type
    = { name : Text
      , description : Optional Text
      , manager : Manager
      , precedence : Precedence
      , connections : List Connection
      , config : { require : RequireConfig, trigger : TriggerConfig }
      }

in  { Config = Config
    , Manager = Manager
    , Precedence = Precedence
    , ManagerValue = ManagerValue
    , RequireConfig = RequireConfig
    , RequireTransform = RequireTransform
    , RequireRender = RequireRender
    , TriggerConfig = TriggerConfig
    , TriggerTransform = TriggerTransform
    , TriggerRender = TriggerRender
    }
