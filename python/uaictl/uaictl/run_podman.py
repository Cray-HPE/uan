#!/usr/bin/env python3
# MIT License
#
# (C) Copyright [2023] Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# coding: utf-8
# pylint: disable=missing-docstring

import argparse
import json
import os
import socket
import subprocess
import sys


cur_file = os.path.basename(__file__)
valid_actions=["list","delete"]
cmd_options={}


def parse_command_line():
    parser = argparse.ArgumentParser()
    parser.add_argument("admin_action", type=str,
                        help="UAI action: list, delete")
    parser.add_argument("-u", "--users", type=str, default="",
                        help="Comma separated list of UAI user names. Default is all.")
    parser.add_argument("-U", "--UAIS", type=str, default="",
                        help="Comma separated list of UAI names.")
    parser.add_argument("-g", "--graphroot", type=str,
                        help="Podman graphroot.")
    parser.add_argument("-v", "--verbose", action="count", default=0,
                        help="Add more output verbosity")
    return parser.parse_args()


def process_args(args):
    """Check argument validity and process options"""
    if args.verbose >= 3:
        print(f"{cur_file}: Command Line args: {args}")

    """Check action"""
    if args.admin_action in valid_actions:
        cmd_options["action"] = args.admin_action
    else:
        print(f"{cur_file}: ERROR: Invalid action: {args.admin_action}")
        print(f"{cur_file}: Valid actions are: {valid_actions}")
        sys.exit(1)

    """Process command line options"""
    cmd_options["users"] = [] if not args.users else args.users.split(",")
    cmd_options["uai_list"] = [] if not args.UAIS else args.UAIS.split(",")
    cmd_options["graphroot"] = args.graphroot
    cmd_options["verbose"] = args.verbose
    if args.verbose:
        print(f'{cur_file}: Action: {cmd_options["action"]}')
        print(f'{cur_file}: Graphroot: {cmd_options["graphroot"]}')
        print(f'{cur_file}: Verbose: {cmd_options["verbose"]}')
        print(f'{cur_file}: Users: {cmd_options["users"]} length: {len(cmd_options["users"])}')
        print(f'{cur_file}: UAIs: {cmd_options["uai_list"]} length: {len(cmd_options["uai_list"])}')
        print(f'{cur_file}: Graphroot: {cmd_options["graphroot"]}')
    return cmd_options


def get_users():
    valid_users=[]
    if os.path.exists(cmd_options["graphroot"]):
        """Get a list of all users UAIs"""
        all_users = [ name for name in os.listdir(cmd_options["graphroot"])
                     if os.path.isdir(cmd_options["graphroot"]+"/"+name)]
        if cmd_options["verbose"]:
            print(f"{cur_file}: All Users: {all_users}")
    else:
        print(f"{cur_file}: ERROR: graphroot doesn't exist. ({cmd_options['graphroot']})")
        sys.exit(1)
    if len(cmd_options["users"]):
        if cmd_options["verbose"]:
            print(f"{cur_file}: {len(cmd_options['users'])} users were specified")
        for user in cmd_options["users"]:
            if user in all_users:
                valid_users.append(user)
    else:
        if cmd_options["verbose"]:
            print(f"{cur_file}: {len(cmd_options['users'])} users were specified")
        valid_users = all_users
    if cmd_options["verbose"]:
        print(f"{cur_file}: VALID_USERS: {valid_users}")
    return valid_users


def run_as_user(user_uid, user_gid):
    def chg_user():
        os.setgid(user_gid)
        os.setuid(user_uid)
    return chg_user


def list_uais():
    """List UAIs on the uai_hosts"""
    users = get_users()
    uai_json_list=[]
    uai_list=[]
    if cmd_options["verbose"]:
        print(f"{cur_file}: UAIs for users: {users}")
    for user in users:
        """Run podman --root cmd_options['graphroot']/user ps"""
        root_path = cmd_options['graphroot'] + "/" + user
        args = ['podman', 'ps', '--root', root_path, '--format=json']
        root_path_stat = os.stat(root_path)
        user_uid = root_path_stat.st_uid
        user_gid = root_path_stat.st_gid
        if cmd_options["verbose"]:
            print(f"UID: {user_uid}; GID: {user_gid}")
        uai_return = subprocess.run(args,
                                      preexec_fn=run_as_user(user_uid, user_gid,),
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE)
        uai_json = json.loads(uai_return.stdout.decode('utf-8'))
        for idx,x in enumerate(uai_json):
            uai_json[idx]['Host'] = socket.gethostname()
            uai_json[idx]['User'] = user
        if cmd_options['verbose']:
            print(f"{cur_file}: podman ps --root {root_path}")
            print(f"{cur_file}: UAI_JSON: {json.dumps(uai_json, indent=2)}")
            print(f"{cur_file}: UAI_NAME: {uai_json[0]['Names']}")
            print(f"{cur_file}: UAI_STDERR: {uai_return.stderr.decode('utf-8')}")
        uai_json_list.append(uai_json)
    return uai_json_list


def delete_uais():
    """Delete a list of UAIs"""
    """ssh to uai_hosts, delete the users uais on those hosts"""
    users = get_users()
    if cmd_options["verbose"]:
        print(f"{cur_file}: USERS: {users}")


def main():
    """Main entry point of run_podman"""
    """check_auth(args)"""
    args = parse_command_line()
    cmd_options = process_args(args)

    """Do the work now"""
    if cmd_options["action"] == "list":
        if args.verbose:
            print(f"{cur_file}: Getting list of UAIs")
        uai_info = list_uais()
        print(f"{json.dumps(uai_info)}", end="")
    elif cmd_options["action"] == "delete":
        if args.verbose:
            print(f"{cur_file}: Delete UAI")
        return delete_uais()
    else:
        print(f"{cur_file}: Unknown action")
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()


