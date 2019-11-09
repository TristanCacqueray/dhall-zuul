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

let PipelineConfig
    : Type
    = { require : PipelineConfigRequire }

let PipelineRenderRequire
    : Type
    = { mapKey : Text, mapValue : ConnectionRequireValue }

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
    , Pipeline = Pipeline
    , PipelineConfigRequire = PipelineConfigRequire
    , PipelineRenderRequire = PipelineRenderRequire
    }
