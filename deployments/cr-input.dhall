{ executor =
    { count = None Natural
    , ssh_key = { key = None Text, secretName = "executor-ssh-key" }
    }
, merger = { count = None Natural, git_user_email = None Text }
, name = "zuul"
}
