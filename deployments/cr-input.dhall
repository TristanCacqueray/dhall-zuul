{ executor =
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
, name = "zuul"
}
