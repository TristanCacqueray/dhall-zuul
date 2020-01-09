{- The zuul operator defined in dhall

The CR inputs as specified in https://zuul-ci.org/docs/zuul/developer/specs/kubernetes-operator.html
is encoded in the Input type below.
-}

let UserSecret = { secretName : Text, key : Optional Text }

let Merger =
      { count : Optional Natural
      , git_user_email : Optional Text
      , git_user_name : Optional Text
      }

let Executor = { count : Optional Natural, ssh_key : UserSecret }

let Web = { count : Optional Natural, status_url : Optional Text }

let Scheduler = { count : Optional Natural, config : UserSecret }

let Input
    : Type
    = { name : Text
      , merger : Merger
      , executor : Executor
      , web : Web
      , scheduler : Scheduler
      , database : Optional UserSecret
      }

let Prelude =
      https://prelude.dhall-lang.org/v12.0.0/package.dhall sha256:aea6817682359ae1939f3a15926b84ad5763c24a3740103202d2eaaea4d01f4c

let Operator = ./Operator.dhall

let Helpers = ./helpers.dhall

let NoService = [] : List Operator.Types.Service

let NoVolume = [] : List Operator.Types.Volume

let NoEnvSecret = [] : List Operator.Types.EnvSecret

let SetService =
          \(service : Operator.Types.Service)
      ->  \(count : Natural)
      ->        if Natural/isZero count

          then  NoService

          else  [ service // { count = count } ]

let DefaultNat =
          \(value : Optional Natural)
      ->  \(default : Natural)
      ->  Optional/fold
            Natural
            value
            Natural
            (\(some : Natural) -> some)
            default

let DefaultText =
          \(value : Optional Text)
      ->  \(default : Text)
      ->  Optional/fold Text value Text (\(some : Text) -> some) default

in  { Input = Input
    , Application =
            \(input : Input)
        ->  let merger-service =
                  SetService
                    Helpers.Services.Merger
                    (DefaultNat input.merger.count 0)

            let merger-email =
                  DefaultText
                    input.merger.git_user_email
                    "${input.name}@localhost"

            let merger-user = DefaultText input.merger.git_user_name "Zuul"

            let executor-service =
                  SetService
                    Helpers.Services.Executor
                    (DefaultNat input.executor.count 1)

            let executor-key-name =
                  DefaultText input.executor.ssh_key.key "id_rsa"

            let web-service =
                  SetService Helpers.Services.Web (DefaultNat input.web.count 1)

            let web-url = DefaultText input.web.status_url "http://web:9000"

            let sched-service =
                  SetService
                    Helpers.Services.Scheduler
                    (DefaultNat input.scheduler.count 1)

            let sched-config =
                  DefaultText input.scheduler.config.key "main.yaml"

            let {- TODO: generate random password -} default-db-password =
                  "super-secret"

            let db-uri =
                  Optional/fold
                    UserSecret
                    input.database
                    Text
                    (\(some : UserSecret) -> "%(ZUUL_DB_URI)")
                    "postgresql://zuul:${default-db-password}@db/zuul"

            let db-service =
                  Optional/fold
                    UserSecret
                    input.database
                    (List Operator.Types.Service)
                    (\(some : UserSecret) -> NoService)
                    [ Helpers.Services.Postgres ]

            let zuul-conf =
                  ''
                  [gearman]
                  server=scheduler

                  [gearman_server]
                  start=true

                  [zookeeper]
                  hosts=zk

                  [merger]
                  git_user_email=${merger-email}
                  git_user_name=${merger-user}

                  [scheduler]
                  tenant_config=/etc/zuul-scheduler/${sched-config}

                  [web]
                  listen_address=0.0.0.0
                  root=${web-url}

                  [executor]
                  private_key_file=/etc/zuul-executor/${executor-key-name}
                  manage_ansible=false

                  [connection "sql"]
                  driver=sql
                  dburi=${db-uri}
                  ''

            in  Operator.Schemas.Application::{
                , name = input.name
                , kind = "zuul"
                , services =
                      db-service
                    # executor-service
                    # merger-service
                    # web-service
                    # sched-service
                , environs = Helpers.DefaultEnv default-db-password
                , volumes =
                        \(serviceType : Operator.Types.ServiceType)
                    ->  let zuul =
                              { name = "zuul"
                              , dir = "/etc/zuul"
                              , files =
                                  [ { path = "zuul.conf", content = zuul-conf }
                                  ]
                              }

                        in  merge
                              { _All = [ zuul ]
                              , Database = NoVolume
                              , Scheduler = [ zuul ]
                              , Launcher = NoVolume
                              , Executor = [ zuul ]
                              , Gateway = [ zuul ]
                              , Worker = [ zuul ]
                              , Config = NoVolume
                              , Other = NoVolume
                              }
                              serviceType
                , secrets =
                        \(serviceType : Operator.Types.ServiceType)
                    ->  let executor-ssh-key =
                              [ Operator.Schemas.Volume::{
                                , name = input.executor.ssh_key.secretName
                                , dir = "/etc/zuul-executor"
                                }
                              ]

                        let sched-config =
                              [ Operator.Schemas.Volume::{
                                , name = input.scheduler.config.secretName
                                , dir = "/etc/zuul-scheduler"
                                }
                              ]

                        in  merge
                              { _All = NoVolume
                              , Database = NoVolume
                              , Scheduler = sched-config
                              , Launcher = NoVolume
                              , Executor = executor-ssh-key
                              , Gateway = NoVolume
                              , Worker = NoVolume
                              , Config = NoVolume
                              , Other = NoVolume
                              }
                              serviceType
                , env-secrets =
                        \(serviceType : Operator.Types.ServiceType)
                    ->  let db-uri =
                              Optional/fold
                                UserSecret
                                input.database
                                (List Operator.Types.EnvSecret)
                                (     \(some : UserSecret)
                                  ->  [ { name = "ZUUL_DB_URI"
                                        , secret = some.secretName
                                        , key = DefaultText some.key "db_uri"
                                        }
                                      ]
                                )
                                NoEnvSecret

                        in  merge
                              { _All = db-uri
                              , Database = NoEnvSecret
                              , Scheduler = db-uri
                              , Launcher = NoEnvSecret
                              , Executor = NoEnvSecret
                              , Gateway = db-uri
                              , Worker = NoEnvSecret
                              , Config = NoEnvSecret
                              , Other = NoEnvSecret
                              }
                              serviceType
                }
    }
