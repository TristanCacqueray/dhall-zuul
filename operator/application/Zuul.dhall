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

let Gerrit =
      { name : Text
      , server : Optional Text
      , user : Text
      , baseurl : Text
      , sshkey : UserSecret
      }

let GitHub = { name : Text, app_id : Natural, app_key : UserSecret }

let Pagure = { name : Text }

let Mqtt = { name : Text }

let GitLab = { name : Text }

let Git = { name : Text, baseurl : Text }

let Input
    : Type
    = { name : Text
      , merger : Merger
      , executor : Executor
      , web : Web
      , scheduler : Scheduler
      , database : Optional UserSecret
      , zookeeper : Optional UserSecret
      , connections :
          { gerrits : Optional (List Gerrit)
          , githubs : Optional (List GitHub)
          , gitlabs : Optional (List GitLab)
          , pagures : Optional (List Pagure)
          , mqtts : Optional (List Mqtt)
          , gits : Optional (List Git)
          }
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

            let zk-hosts =
                  Optional/fold
                    UserSecret
                    input.zookeeper
                    Text
                    (\(some : UserSecret) -> "%(ZUUL_ZK_HOSTS)")
                    "zk"

            let zk-service =
                  Optional/fold
                    UserSecret
                    input.zookeeper
                    (List Operator.Types.Service)
                    (\(some : UserSecret) -> NoService)
                    [ Helpers.Services.ZooKeeper ]

            let gerrits-conf =
                  Helpers.mkConns
                    Gerrit
                    input.connections.gerrits
                    (     \(gerrit : Gerrit)
                      ->  let key = DefaultText gerrit.sshkey.key "id_rsa"

                          let server = DefaultText gerrit.server gerrit.name

                          in  ''
                              [connection ${gerrit.name}]
                              driver=gerrit
                              server=${server}
                              sshkey=/etc/zuul-gerrit-${gerrit.name}/${key}
                              user=${gerrit.user}
                              baseurl=${gerrit.baseurl}
                              ''
                    )

            let gits-conf =
                  Helpers.mkConns
                    Git
                    input.connections.gits
                    (     \(git : Git)
                      ->  ''
                          [connection ${git.name}]
                          driver=git
                          baseurl=${git.baseurl}

                          ''
                    )

            let zuul-conf =
                      ''
                      [gearman]
                      server=scheduler

                      [gearman_server]
                      start=true

                      [zookeeper]
                      hosts=${zk-hosts}

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
                  ++  gits-conf
                  ++  gerrits-conf

            in  Operator.Schemas.Application::{
                , name = input.name
                , kind = "zuul"
                , services =
                      db-service
                    # zk-service
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

                        let gerrits-key =
                              Helpers.mkConnVols
                                Gerrit
                                input.connections.gerrits
                                (     \(gerrit : Gerrit)
                                  ->  Operator.Schemas.Volume::{
                                      , name = gerrit.sshkey.secretName
                                      , dir = "/etc/zuul-gerrit-${gerrit.name}"
                                      }
                                )

                        in  merge
                              { _All = NoVolume
                              , Database = NoVolume
                              , Scheduler = sched-config # gerrits-key
                              , Launcher = NoVolume
                              , Executor = executor-ssh-key # gerrits-key
                              , Gateway = NoVolume
                              , Worker = gerrits-key
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

                        let zk-hosts =
                              Optional/fold
                                UserSecret
                                input.zookeeper
                                (List Operator.Types.EnvSecret)
                                (     \(some : UserSecret)
                                  ->  [ { name = "ZUUL_ZK_HOSTS"
                                        , secret = some.secretName
                                        , key = DefaultText some.key "hosts"
                                        }
                                      ]
                                )
                                NoEnvSecret

                        in  merge
                              { _All = db-uri # zk-hosts
                              , Database = NoEnvSecret
                              , Scheduler = db-uri # zk-hosts
                              , Launcher = zk-hosts
                              , Executor = NoEnvSecret
                              , Gateway = db-uri # zk-hosts
                              , Worker = NoEnvSecret
                              , Config = NoEnvSecret
                              , Other = NoEnvSecret
                              }
                              serviceType
                }
    }
