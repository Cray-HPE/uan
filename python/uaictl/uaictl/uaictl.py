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
import subprocess
import sys


"""Allowable admin actions and output formats are defined here"""
valid_actions=["list-users", "list-uais","delete-uais"]
valid_formats=["json","yaml"]
default_graphroot="/scratch/containers"
cmd_options={}


def validate_user(args):
    """You must be root to use this command."""
    if args.verbose:
        print("Checking user uid...", file=sys.stderr)
    if os.getuid():
        print("Must be root to use this command. Exiting.", file=sys.stderr)
        sys.exit(1)


def parse_command_line():
    parser = argparse.ArgumentParser()
    parser.add_argument("admin_action", type=str,
                        help="UAI action: " + str(valid_actions))
    parser.add_argument("-u", "--users", type=str, default="",
                        help="Comma separated list of UAI user names to use. Default is all users.")
    parser.add_argument("-H", "--Hosts", type=str,
                        help="Comma separated list of UAI host names to use. Default is all hosts.")
    parser.add_argument("-U", "--UAIS", type=str, default="",
                        help="Comma separated list of UAI names to use. Default is all UAIs.")
    parser.add_argument("-f", "--format", type=str,
                        help="Output format: " + str(valid_formats))
    parser.add_argument("-g", "--graphroot", type=str, default=default_graphroot,
                        help="Podman graphroot. Default=" + default_graphroot + ".")
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

    """Check output formats"""
    if args.format:
        if args.format in valid_formats:
            cmd_options["format"] = args.format
        else:
            print(f"ERROR: Invalid output format: {args.format}", file=sys.stderr)
            print(f"Valid output formats are: {valid_formats}", file=sys.stderr)
            sys.exit(1)
    else:
        cmd_options["format"] = "default"

    """Process command line options"""
    cmd_options["users"] = [] if not args.users else args.users.split(",")
    cmd_options["uai_hosts"] = [] if not args.Hosts else args.Hosts.split(",")
    cmd_options["uai_list"] = [] if not args.UAIS else args.UAIS.split(",")
    cmd_options["graphroot"] = args.graphroot
    cmd_options["verbose"] = args.verbose
    if args.verbose:
        print(f'Action: {cmd_options["action"]}', file=sys.stderr)
        print(f'Format: {cmd_options["format"]}', file=sys.stderr)
        print(f'Graphroot: {cmd_options["graphroot"]}',
              file=sys.stderr)
        print(f'Verbose: {cmd_options["verbose"]}', file=sys.stderr)
        print(f'Users: {cmd_options["users"]} length: {len(cmd_options["users"])}',
              file=sys.stderr)
        print(f'Hosts: {cmd_options["uai_hosts"]} length: {len(cmd_options["uai_hosts"])}',
              file=sys.stderr)
        print(f'UAIs: {cmd_options["uai_list"]} length: {len(cmd_options["uai_list"])}',
              file=sys.stderr)
        print(f'Graphroot: {cmd_options["graphroot"]}', file=sys.stderr)
    return cmd_options


def get_hosts():
    """Get all the UAI Hosts to operate on"""
    all_hosts=[]
    all_xnames=[]
    groups=['k3s_server', 'k3s_agent']
    if not cmd_options["uai_hosts"]:
        """Get dictionary of xname:hostname"""
        args = ['sat', 'status', '--filter', 'SubRole=UAN', '--no-heading',
                '--no-border', '--fields', 'xname,Aliases', '--format', 'json']
        uan_map = subprocess.run(args,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE)
        uan_map_json = json.loads(uan_map.stdout.decode('utf-8'))
        for group in groups:
            args = ['cray', 'hsm', 'groups', 'describe', group,
                    '--format', 'json']
            k3s_group = subprocess.run(args,
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE)
            k3s_group_json = json.loads(k3s_group.stdout.decode('utf-8'))
            all_xnames += k3s_group_json['members']['ids']
        for xname in all_xnames:
            """Find hostname from xname"""
            for uan in uan_map_json:
                if xname == uan["xname"]:
                  all_hosts.append(uan["Aliases"])
                  break
    else:
        if cmd_options['verbose']:
            print(f"ALL_HOSTS: {all_hosts}", file=sys.stderr)
        all_hosts = cmd_options["uai_hosts"]
    return all_hosts


def run_cmd(cmd):
    """Run cmd on the uai_hosts"""
    """ssh to uai_hosts, run cmd for the desired users and UAIs"""
    uai_return_list=[]
    uai_stderr_list=[]
    user_list=[]
    uai_list=[]
    uai_hosts = get_hosts()
    graphroot = cmd_options['graphroot']
    user_list = cmd_options['users']
    uai_list = cmd_options['uai_list']
    verbose = cmd_options['verbose']
    remote_cmd = 'python3 - ' + cmd + ' -g ' + graphroot
    if user_list:
        users = ','.join([str(user) for user in user_list])
        remote_cmd += ' -u ' + users
    if uai_list:
        uais = ','.join([str(uai) for uai in uai_list])
        remote_cmd += ' -U ' + uais
    if cmd_options["verbose"]:
        print(f"HOSTS: {uai_hosts}", file=sys.stderr)
        for x in range(0, cmd_options['verbose']):
            remote_cmd += ' -v '
    for host in uai_hosts:
        p1 = subprocess.Popen(['cat', 'run_podman.py'], stdout=subprocess.PIPE)
        uai_return = subprocess.run(['ssh', host, remote_cmd], stdin=p1.stdout,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        uais = uai_return.stdout.decode('utf-8')
        errs = uai_return.stderr.decode('utf-8')
        if not (uais == "[]" or uais == ""):
            uai_return_list.append(uais)
        if errs != "":
            uai_stderr_list.append(host + ": " + errs)
    return uai_return_list, uai_stderr_list


def main():
    """Main entry point of uaictl"""
    args = parse_command_line()
    validate_user(args)
    cmd_options = process_args(args)

    """Do the work now"""
    if args.verbose:
        print(f"Getting list of UAIs", file=sys.stderr)
    uai_info, uai_errs = run_cmd(cmd_options["action"])
    for i in uai_info:
        if i != "":
            print(f"{i}") 
    if uai_errs:
        print(f"ERRORS:", file=sys.stderr)
        for e in uai_errs:
            print(f"{e}", file=sys.stderr)

    sys.exit(0)


if __name__ == '__main__':
    main()

