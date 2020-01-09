{- The zuul operator defined in dhall

The CR inputs as specified in https://zuul-ci.org/docs/zuul/developer/specs/kubernetes-operator.html
is encoded in the Input type below.
-}

let UserSecret = { secretName : Text, key : Optional Text }

let Merger = { count : Optional Natural, git_user_email : Optional Text }

let Executor = { count : Optional Natural, ssh_key : UserSecret }

let Input
    : Type
    = { name : Text, merger : Merger, executor : Executor }

let Prelude =
      https://prelude.dhall-lang.org/v12.0.0/package.dhall sha256:aea6817682359ae1939f3a15926b84ad5763c24a3740103202d2eaaea4d01f4c

let Operator = ./Operator.dhall

let Helpers = ./helpers.dhall

let NoService = [] : List Operator.Types.Service

let NoVolume = [] : List Operator.Types.Volume

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
                  DefaultText input.merger.git_user_email "zuul@${input.name}"

            let executor-service =
                  SetService
                    Helpers.Services.Executor
                    (DefaultNat input.executor.count 1)

            let executor-key-name =
                  DefaultText input.executor.ssh_key.key "id_rsa"

            let zuul-conf =
                  ''
                  [gearman]
                  server=scheduler

                  [zookeeper]
                  hosts=zk

                  [merger]
                  git_user_email=${merger-email}

                  [gearman_server]
                  start=true

                  [scheduler]
                  tenant_config=/etc/zuul/main.yaml

                  [web]
                  listen_address=0.0.0.0

                  [executor]
                  private_key_file=/etc/zuul-executor/${executor-key-name}

                  ''

            in  Operator.Schemas.Application::{
                , name = input.name
                , kind = "zuul"
                , services = executor-service # merger-service
                , environs = Helpers.DefaultEnv "db-pass"
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

                        in  merge
                              { _All = NoVolume
                              , Database = NoVolume
                              , Scheduler = NoVolume
                              , Launcher = NoVolume
                              , Executor = executor-ssh-key
                              , Gateway = NoVolume
                              , Worker = NoVolume
                              , Config = NoVolume
                              , Other = NoVolume
                              }
                              serviceType
                }
    }
