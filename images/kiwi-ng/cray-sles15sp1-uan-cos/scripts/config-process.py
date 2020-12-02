#!/usr/bin/env python3
# Copyright 2020 Hewlett Packard Enterprise Development LP

# Process values for the Kiwi image build depending on the build environment
# (cje=Jenkins pipeline, shasta=shasta on-system image).
# This is a generic script that takes in j2 templates and renders them.
import os
import sys

import argparse
from jinja2 import Environment, FileSystemLoader, Template
import yaml

# Create command line arg parser
parser = argparse.ArgumentParser(usage='./{0} [--input <input>] [--output <output>] <values_file>'.format(sys.argv[0]))
parser.add_argument('-i', '--input')
parser.add_argument('-o', '--output')
parser.add_argument('values_file')
args = parser.parse_args(sys.argv[1:])

env = Environment(loader=FileSystemLoader('./'))

# Seed the template rendering values with the environment variables
values = {"env": os.environ}

# Get input values and template them if required
with open(args.values_file, 'r') as data:
    values.update(yaml.safe_load(data))

repos = []
for repo in values['repos']:
    repo["path"] = Template(repo["path"]).render(**values)
    repos.append(repo)
    from pprint import pprint
    pprint(repo)

values['repos'] = repos
template = env.get_template(args.input)

# Generate output file
with open(args.output, 'w') as output:
    output.write(template.render(values=values))
    output.write('\n')
