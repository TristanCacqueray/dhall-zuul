let Connection = ./connection.dhall

let Pagure = ./pagure.dhall

let Gerrit = ./gerrit.dhall

let Mqtt = ./mqtt.dhall

let RequireConfig
    : Type
    = { Gerrit : Gerrit.Require, Pagure : Pagure.Require }

let RequireValue
    : Type
    = < Gerrit : Gerrit.RequireValue
      | Pagure : Pagure.Require
      | Incorrect : Text
      >

let RequireTransform =
        λ(connection : Connection)
      → λ(config : RequireConfig)
      → { Gerrit = RequireValue.Gerrit (config.Gerrit connection)
        , Pagure = RequireValue.Pagure config.Pagure
        , Mqtt = RequireValue.Incorrect "todo: add exception"
        }

let RequireRender
    : Type
    = { mapKey : Text, mapValue : RequireValue }

let TriggerConfig
    : Type
    = { Gerrit : Gerrit.Trigger, Pagure : List Pagure.Trigger }

let TriggerValue
    : Type
    = < Gerrit : List Gerrit.TriggerValue
      | Pagure : List Pagure.Trigger
      | Incorrect : Text
      >

let TriggerTransform =
        λ(connection : Connection)
      → λ(config : TriggerConfig)
      → { Gerrit = TriggerValue.Gerrit (config.Gerrit connection)
        , Pagure = TriggerValue.Pagure config.Pagure
        , Mqtt = TriggerValue.Incorrect "todo: add exception"
        }

let TriggerRender
    : Type
    = { mapKey : Text, mapValue : TriggerValue }

let StatusConfig
    : Type
    = { Gerrit : Gerrit.Status, Pagure : Pagure.Status, Mqtt : Mqtt.Status }

let StatusValue
    : Type
    = < Gerrit : Gerrit.StatusValue
      | Pagure : Pagure.Status
      | Mqtt : Mqtt.Status
      >

let StatusTransform =
        λ(connection : Connection)
      → λ(config : StatusConfig)
      → { Gerrit = StatusValue.Gerrit (config.Gerrit connection)
        , Pagure = StatusValue.Pagure config.Pagure
        , Mqtt = StatusValue.Mqtt config.Mqtt
        }

let StatusRender
    : Type
    = { mapKey : Text, mapValue : StatusValue }

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
      , config :
          { require : RequireConfig
          , trigger : TriggerConfig
          , start : StatusConfig
          , success : StatusConfig
          , failure : StatusConfig
          }
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
    , StatusConfig = StatusConfig
    , StatusTransform = StatusTransform
    , StatusRender = StatusRender
    }
