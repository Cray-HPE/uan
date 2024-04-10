#!/usr/bin/env python3
# MIT License
#
# (C) Copyright [2024] Hewlett Packard Enterprise Development LP
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


valid_actions=["list-users", "list-uais", "delete-uais"]
default_graphroot="/scratch/containers"
cmd_options={}


def parse_command_line():
    parser = argparse.ArgumentParser()
    parser.add_argument("admin_action", type=str,
                        help="UAI action: list, delete")
    parser.add_argument("-u", "--users", type=str, default="",
                        help="Comma separated list of UAI user names to use. Default is all users.")
    parser.add_argument("-U", "--UAIS", type=str, default="",
                        help="Comma separated list of UAI names. Default is all UAIs.")
    parser.add_argument("-g", "--graphroot", type=str, default=default_graphroot,
                        help="Podman graphroot. Default=" + default_graphroot +".")
    parser.add_argument("-v", "--verbose", action="count", default=0,
                        help="Add more output verbosity")
    return parser.parse_args()


def process_args(args):
    """Check argument validity and process options"""
    if args.verbose >= 3:
        print(f"Command Line args: {args}", file=sys.stderr)

    """Check action"""
    if args.admin_action in valid_actions:
        cmd_options["action"] = args.admin_action
    else:
        print(f"ERROR: Invalid action: {args.admin_action}", file=sys.stderr)
        print(f"Valid actions are: {valid_actions}", file=sys.stderr)
        sys.exit(1)

    """Process command line options"""
    cmd_options["users"] = [] if not args.users else args.users.split(",")
    cmd_options["uai_list"] = [] if not args.UAIS else args.UAIS.split(",")
    cmd_options["graphroot"] = args.graphroot
    cmd_options["verbose"] = args.verbose
    if args.verbose:
        print(f'Action: {cmd_options["action"]}', file=sys.stderr)
        print(f'Graphroot: {cmd_options["graphroot"]}',
              file=sys.stderr)
        print(f'Verbose: {cmd_options["verbose"]}',
              file=sys.stderr)
        print(f'Users: {cmd_options["users"]} length: {len(cmd_options["users"])}',
              file=sys.stderr)
        print(f'UAIs: {cmd_options["uai_list"]} length: {len(cmd_options["uai_list"])}',
              file=sys.stderr)
        print(f'Graphroot: {cmd_options["graphroot"]}',
              file=sys.stderr)
    return cmd_options


def get_users():
    valid_users=[]
    if os.path.exists(cmd_options["graphroot"]):
        """Get a list of all users UAIs"""
        all_users = [ name for name in os.listdir(cmd_options["graphroot"])
                     if os.path.isdir(cmd_options["graphroot"]+"/"+name)]
        if cmd_options["verbose"]:
            print(f"All Users: {all_users}", file=sys.stderr)
    else:
        print(f"ERROR: graphroot doesn't exist. ({cmd_options['graphroot']})",
              file=sys.stderr)
        sys.exit(1)
    if cmd_options["users"]:
        if cmd_options["verbose"]:
            print(f"{len(cmd_options['users'])} users were specified",
                  file=sys.stderr)
        for user in cmd_options["users"]:
            if user in all_users:
                valid_users.append(user)
    else:
        if cmd_options["verbose"]:
            print(f"{len(cmd_options['users'])} users were specified",
                  file=sys.stderr)
        valid_users = all_users
    if cmd_options["verbose"]:
        print(f"VALID_USERS: {valid_users}", file=sys.stderr)
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
        print(f"UAIs for users: {users}", file=sys.stderr)
    for user in users:
        """Run podman --root cmd_options['graphroot']/user ps"""
        root_path = cmd_options['graphroot'] + "/" + user
        args = ['podman', 'ps', '--root', root_path, '--format=json']
        root_path_stat = os.stat(root_path)
        user_uid = root_path_stat.st_uid
        user_gid = root_path_stat.st_gid
        if cmd_options["verbose"]:
            print(f"UID: {user_uid}; GID: {user_gid}", file=sys.stderr)
        uai_return = subprocess.run(args,
                                      preexec_fn=run_as_user(user_uid, user_gid,),
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE)
        uai_json = json.loads(uai_return.stdout.decode('utf-8'))
        for idx,x in enumerate(uai_json):
            uai_json[idx]['Host'] = socket.gethostname()
            uai_json[idx]['User'] = user
        if cmd_options['verbose']:
            print(f"podman ps --root {root_path}", file=sys.stderr)
            print(f"UAI_JSON: {json.dumps(uai_json, indent=2)}",
                  file=sys.stderr)
            print(f"UAI_NAME: {uai_json[0]['Names']}",
                  file=sys.stderr)
            print(f"UAI_STDERR: {uai_return.stderr.decode('utf-8')}",
                  file=sys.stderr)
        uai_json_list.append(uai_json)
    return uai_json_list


def delete_uais():
    """Delete a list of UAIs"""
    """ssh to uai_hosts, delete the users uais on those hosts"""
    users = get_users()
    if cmd_options["verbose"]:
        print(f"USERS: {users}", file=sys.stderr)


def main():
    """Main entry point of run_podman"""
    """check_auth(args)"""
    args = parse_command_line()
    cmd_options = process_args(args)

    """Do the work now"""
    if cmd_options["action"] == "list-users":
        if args.verbose:
            print(f"Getting list of UAI users", file=sys.stderr)
        uai_users = {
                "Host": socket.gethostname(),
                "Users": get_users()
                }
        print(f"{json.dumps(uai_users)}", end="")
    elif cmd_options["action"] == "list-uais":
        if args.verbose:
            print(f"Getting list of UAIs", file=sys.stderr)
        uai_info = list_uais()
        print(f"{json.dumps(uai_info)}", end="")
    elif cmd_options["action"] == "delete-uais":
        if args.verbose:
            print(f"Delete UAI", file=sys.stderr)
        return delete_uais()
    else:
        print(f"Unknown action", file=sys.stderr)
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()


