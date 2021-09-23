#!/usr/bin/env python3
# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# (MIT License)


import argparse
import yaml
import hashlib
import json
import re

ARTIFACT_MAPPING = {
    "kernel":          "application/vnd.cray.image.kernel",
    "vmlinuz":         "application/vnd.cray.image.kernel",
    "initrd":          "application/vnd.cray.image.initrd",
    "squashfs":        "application/vnd.cray.image.rootfs.squashfs",
    "tar.xz":          "application/vnd.cray.image.rootfs.tar",
    "boot_parameters": "application/vnd.cray.image.parameters.boot",
}

artifact_list = []


def create_manifest(files, distro, image_name):
    global artifact_list
    recipe_info = {}
    for f_name in files:
        # Not a fan of this next line, still thinking.
        if "recipe" in f_name:
            recipe_info = update_recipe_list(f_name, distro)
            continue
        for key, value in ARTIFACT_MAPPING.items():
            if key in f_name:
                artifact_list.append(update_artifact_list(f_name, value))

    dict_info = {
        'version': "1.0.0",
        'images': {
            f'{image_name}': {
                'artifacts': artifact_list
            }
        },
        'recipes': {
            f'{image_name}': recipe_info
        }
    }
    with open(r'manifest.yaml', 'w') as file:
        yaml.dump(dict_info, file)


def update_artifact_list(artifact, arti_type):
    original_artifact = artifact
    artifact = re.sub('^(.*[\\\/])', '', artifact)
    new_item = {
        'link': {
            'path': f'/{artifact}',
            'type': 'file'
        },
        'md5': f'{get_md5sum(original_artifact)}',
        'type': f'{arti_type}'
    }
    return new_item


def update_recipe_list(recipe, distro):
    original_recipe = recipe
    recipe = re.sub('^(.*[\\\/])', '', recipe)
    new_item = {
        'link': {
            'path': f'/{recipe}',
            'type': 'file'
        },
        'md5': f'{get_md5sum(original_recipe)}',
        'linux_distribution': f'{distro}',
        'recipe_type': 'kiwi-ng'
    }

    return new_item


def get_md5sum(filename):
    """ Utility for efficient md5sum of a file """
    hashmd5 = hashlib.md5()
    with open(filename, "rb") as afile:
        for chunk in iter(lambda: afile.read(4096), b""):
            hashmd5.update(chunk)
    return hashmd5.hexdigest()


def create_arg_parser():
    parser = argparse.ArgumentParser(description='Creates a manifest file to be consumed by the a docker image.')
    parser.add_argument('image_name', type=str,
                        help='Name of the kiwi image and kiwi recipe.')
    parser.add_argument('--files', type=str, help='List of files to update the manifest file with.')
    parser.add_argument('--distro', type=str, help='Distribution type.')
    args = parser.parse_args()
    args.files = list(args.files.split())

    return args

def main():
    args = create_arg_parser()
    create_manifest(args.files, args.distro, args.image_name)

if __name__ == '__main__':
    main()
