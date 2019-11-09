{- Zuul configuration types
-}

let ConnectionType
    : Type
    = < Gerrit | Pagure >

let Connection
    : Type
    = { name : Text, type : ConnectionType }

let GerritRequire
    : Type
    = { open : Optional Bool, current-patchset : Optional Bool }

let PagureRequire
    : Type
    = { merged : Optional Bool }

let ConnectionRequireValue
    : Type
    = < Gerrit : GerritRequire | Pagure : PagureRequire >

let PipelineConfigRequire
    : Type
    = { Gerrit : ConnectionRequireValue, Pagure : ConnectionRequireValue }

let GerritTrigger
    : Type
    = { event : Text }

let PagureTrigger
    : Type
    = { event : Text, action : Text }

let ConnectionTriggerValue
    : Type
    = < Gerrit : List GerritTrigger | Pagure : List PagureTrigger >

let PipelineConfigTrigger
    : Type
    = { Gerrit : ConnectionTriggerValue, Pagure : ConnectionTriggerValue }

let PipelineConfig
    : Type
    = { require : PipelineConfigRequire, trigger : PipelineConfigTrigger }

let PipelineRenderRequire
    : Type
    = { mapKey : Text, mapValue : ConnectionRequireValue }

let PipelineRenderTrigger
    : Type
    = { mapKey : Text, mapValue : ConnectionTriggerValue }

let Pipeline
    : Type
    = { name : Text
      , description : Optional Text
      , connections : List Connection
      , config : PipelineConfig
      }

in  { Connection = Connection
    , ConnectionType = ConnectionType
    , ConnectionRequireValue = ConnectionRequireValue
    , ConnectionTriggerValue = ConnectionTriggerValue
    , Pipeline = Pipeline
    , PipelineConfigRequire = PipelineConfigRequire
    , PipelineConfigTrigger = PipelineConfigTrigger
    , PipelineRenderRequire = PipelineRenderRequire
    , PipelineRenderTrigger = PipelineRenderTrigger
    }
