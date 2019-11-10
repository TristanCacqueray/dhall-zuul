{- Zuul configuration types
-}

let Connection = ./types/connection.dhall

let ConnectionType = ./types/connections.dhall

let Pagure = ./types/pagure.dhall

let Gerrit = ./types/gerrit.dhall

let PipelineRequireValue
    : Type
    = < Gerrit : Gerrit.Require | Pagure : Pagure.Require >

let PipelineRequireConfig
    : Type
    = { Gerrit : Gerrit.Require, Pagure : Pagure.Require }

let PipelineRequireRender
    : Type
    = { mapKey : Text, mapValue : PipelineRequireValue }

let PipelineRequireTransform =
        λ(config : PipelineRequireConfig)
      → { Gerrit = PipelineRequireValue.Gerrit config.Gerrit
        , Pagure = PipelineRequireValue.Pagure config.Pagure
        }

let PipelineTriggerValue
    : Type
    = < Gerrit : List Gerrit.Trigger | Pagure : List Pagure.Trigger >

let PipelineTriggerConfig
    : Type
    = { Gerrit : List Gerrit.Trigger, Pagure : List Pagure.Trigger }

let PipelineTriggerTransform =
        λ(config : PipelineTriggerConfig)
      → { Gerrit = PipelineTriggerValue.Gerrit config.Gerrit
        , Pagure = PipelineTriggerValue.Pagure config.Pagure
        }

let PipelineTriggerRender
    : Type
    = { mapKey : Text, mapValue : PipelineTriggerValue }

let Pipeline
    : Type
    = { name : Text
      , description : Optional Text
      , connections : List Connection
      , config :
          { require : PipelineRequireConfig, trigger : PipelineTriggerConfig }
      }

in  { Pagure = Pagure
    , Gerrit = Gerrit
    , Connection = Connection
    , ConnectionType = ConnectionType
    , Pipeline = Pipeline
    , PipelineRequireConfig = PipelineRequireConfig
    , PipelineRequireTranform = PipelineRequireTransform
    , PipelineRequireRender = PipelineRequireRender
    , PipelineTriggerConfig = PipelineTriggerConfig
    , PipelineTriggerTransform = PipelineTriggerTransform
    , PipelineTriggerRender = PipelineTriggerRender
    }
