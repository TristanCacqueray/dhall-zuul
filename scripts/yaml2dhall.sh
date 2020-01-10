#!/bin/sh
# A convenient script to convert a cr spec into a dhall object
./operator/roles/zuul/library/json_to_dhall.py '(./operator/application/Zuul.dhall).Input' --file $1
