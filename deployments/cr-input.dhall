let Secret =
      { Type = { key : Optional Text, secretName : Text }
      , default = { key = None Text }
      }

let Conn = { name : Text }

in  { executor =
        { count = None Natural
        , ssh_key = { key = None Text, secretName = "executor-ssh-key" }
        }
    , merger =
        { count = None Natural
        , git_user_email = None Text
        , git_user_name = None Text
        }
    , scheduler =
        { count = None Natural
        , config = { key = None Text, secretName = "zuul-yaml-conf" }
        }
    , web = { count = None Natural, status_url = None Text }
    , database = None { key : Optional Text, secretName : Text }
    , zookeeper = None { key : Optional Text, secretName : Text }
    , name = "zuul"
    , connections =
        { gerrits =
            Some
              [ { name = "review.rdoproject.org"
                , server = None Text
                , sshkey = Secret::{ secretName = "rdo-key" }
                , user = "zuul"
                , baseurl = "https://review.rdoproject.org/r/"
                }
              ]
        , githubs =
            None (List { name : Text, app_id : Natural, app_key : Secret.Type })
        , gitlabs = None (List Conn)
        , pagures = None (List Conn)
        , mqtts = None (List Conn)
        , gits =
            Some [ { name = "opendev.org", baseurl = "https://opendev.org" } ]
        }
    }
