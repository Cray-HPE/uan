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
import subprocess
import sys


cur_file = os.path.basename(__file__)
"""Allowable admin actions and output formats are defined here"""
valid_actions=["list","delete"]
valid_formats=["json","yaml"]
cmd_options={}


def check_auth(args):
    """You must be root to run this command."""
    if args.verbose:
        print("{cur_file}: Checking user uid...")
    if os.getuid():
        print("{cur_file}: Must be root to run this command. Exiting.")
        sys.exit(1)


def parse_command_line():
    parser = argparse.ArgumentParser()
    parser.add_argument("admin_action", type=str,
                        help="UAI action: list, delete")
    parser.add_argument("-u", "--users", type=str, default="",
                        help="Comma separated list of UAI user names. Default is all.")
    parser.add_argument("-H", "--Hosts", type=str,
                        help="Comma separated list of UAI host names. Default is all.")
    parser.add_argument("-U", "--UAIS", type=str, default="",
                        help="Comma separated list of UAI names.")
    parser.add_argument("-f", "--format", type=str,
                        help="Output format: json, yaml")
    parser.add_argument("-g", "--graphroot", type=str, default="/scratch/containers",
                        help="Podman graphroot. Default=/scratch/containers.")
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

    """Check output formats"""
    if args.format:
        if args.format in valid_formats:
            cmd_options["format"] = args.format
        else:
            print(f"{cur_file}: ERROR: Invalid output format: {args.format}")
            print(f"{cur_file}: Valid output formats are: {valid_formats}")
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
        print(f'{cur_file}: Action: {cmd_options["action"]}')
        print(f'{cur_file}: Format: {cmd_options["format"]}')
        print(f'{cur_file}: Graphroot: {cmd_options["graphroot"]}')
        print(f'{cur_file}: Verbose: {cmd_options["verbose"]}')
        print(f'{cur_file}: Users: {cmd_options["users"]} length: {len(cmd_options["users"])}')
        print(f'{cur_file}: Hosts: {cmd_options["uai_hosts"]} length: {len(cmd_options["uai_hosts"])}')
        print(f'{cur_file}: UAIs: {cmd_options["uai_list"]} length: {len(cmd_options["uai_list"])}')
        print(f'{cur_file}: Graphroot: {cmd_options["graphroot"]}')
    return cmd_options


def get_hosts():
    """Get all the UAI Hosts to operate on"""
    all_hosts=[]
    all_xnames=[]
    groups=['k3s_server', 'k3s_agent']
    if not len(cmd_options["uai_hosts"]):
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
            print(f"{cur_file}: ALL_HOSTS: {all_hosts}")
        all_hosts = cmd_options["uai_hosts"]
    return all_hosts


def list_uais():
    """List UAIs on the uai_hosts"""
    """ssh to uai_hosts, run podman ps for the desired users"""
    uai_return_list=[]
    uai_stderr_list=[]
    user_list=[]
    uai_list=[]
    uai_hosts = get_hosts()
    graphroot = cmd_options['graphroot']
    user_list = cmd_options['users']
    uai_list = cmd_options['uai_list']
    verbose = cmd_options['verbose']
    remote_cmd = 'python3 - list -g ' + graphroot
    if len(user_list):
        users = ','.join([str(user) for user in user_list])
        remote_cmd += ' -u ' + users
    if len(uai_list):
        uais = ','.join([str(uai) for uai in uai_list])
        remote_cmd += ' -U ' + uais
    if cmd_options["verbose"]:
        print(f"{cur_file}: HOSTS: {uai_hosts}")
        for x in range(0, cmd_options['verbose']):
            remote_cmd += ' -v '
    for host in uai_hosts:
        p1 = subprocess.Popen(['cat', 'run_podman.py'], stdout=subprocess.PIPE)
        uai_return = subprocess.run(['ssh', host, remote_cmd], stdin=p1.stdout,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        uais = uai_return.stdout.decode('utf-8')
        errs = uai_return.stderr.decode('utf-8')
        if not (uais == "[]" or uais == ""):
            uai_return_list.append(host + ": " + uais)
        if errs != "":
            uai_stderr_list.append(host + ": " + errs)
    return uai_return_list, uai_stderr_list


def delete_uais():
    """Delete a list of UAIs"""
    """ssh to uai_hosts, delete the users uais on those hosts"""
    uai_hosts = get_hosts()
    if cmd_options["verbose"]:
        print(f"{cur_file}: HOSTS: {uai_hosts}")
    for host in uai_hosts:
        subprocess.run(['cat', 'run_podman.py', '|', 'ssh',
                                        host, 'python', '-', 'delete',
                                        '-g', cmd_options['graphroot'],
                                        '-u', cmd_options['users'],
                                        '-U', cmd_options['uai_list'],
                                        '-v', cmd_options['verbose']],
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE)


def main():
    """Main entry point of uaictl"""
    """check_auth(args)"""
    args = parse_command_line()
    cmd_options = process_args(args)

    """Do the work now"""
    if cmd_options["action"] == "list":
        if args.verbose:
            print(f"{cur_file}: Getting list of UAIs")
        uai_info, uai_errs = list_uais()
        for i in uai_info:
            if i != "":
                print(f"{i}") 
        if len(uai_errs):
            print(f"Errors:")
            for e in uai_errs:
                print(f"{e}")
    elif cmd_options["action"] == "delete":
        if args.verbose:
            print(f"{cur_file}: Delete UAI")
        delete_uais()
    else:
        print(f"{cur_file}: Unknown action")
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()

