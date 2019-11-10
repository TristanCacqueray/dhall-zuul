let ConnectionType = ./connections.dhall

let Connection
    : Type
    = { name : Text, type : ConnectionType, user : Optional Text }

in  Connection
