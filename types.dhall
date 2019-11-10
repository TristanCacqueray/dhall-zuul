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
    = { Gerrit : GerritRequire, Pagure : PagureRequire }

let PipelineConfigRequireTransform =
        λ(config : PipelineConfigRequire)
      → { Gerrit = ConnectionRequireValue.Gerrit config.Gerrit
        , Pagure = ConnectionRequireValue.Pagure config.Pagure
        }

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
    = { Gerrit : List GerritTrigger, Pagure : List PagureTrigger }

let PipelineConfigTriggerTransform =
        λ(config : PipelineConfigTrigger)
      → { Gerrit = ConnectionTriggerValue.Gerrit config.Gerrit
        , Pagure = ConnectionTriggerValue.Pagure config.Pagure
        }

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
    , Pipeline = Pipeline
    , PipelineConfigRequire = PipelineConfigRequire
    , PipelineConfigRequireTranform = PipelineConfigRequireTransform
    , PipelineConfigTrigger = PipelineConfigTrigger
    , PipelineConfigTriggerTransform = PipelineConfigTriggerTransform
    , PipelineRenderRequire = PipelineRenderRequire
    , PipelineRenderTrigger = PipelineRenderTrigger
    }
