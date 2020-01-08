#!/usr/bin/env python3
# Copyright 2020 Red Hat, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

from ansible.module_utils.basic import AnsibleModule  # type: ignore

# TODO: implementation

module = AnsibleModule(
        argument_spec=dict(
            name=dict(required=True, type='str'),
        )
    )
p = module.params
module.exit_json(changed=True, result=dict(
    name=p['name'],
    ssh_key='test',
    connection=dict(
        name="opendev.org",
        driver="git",
        params=dict(bareurl="https://opendev.org")
    ),
    projects=[
        "zuul/zuul-base-jobs",
        "zuul/zuul-jobs"
    ]
))
