#!/usr/bin/env python3
# Copyright 2020 Hewlett Packard Enterprise Development LP
# Process values for the Kiwi image build depending on the build environment
# (cje=Jenkins pipeline, shasta=shasta on-system image).
# This is a generic script that takes in j2 templates and renders them.

from io import StringIO
import sys
import yaml
from jinja2 import Environment, FileSystemLoader, Template
import argparse

# Create command line arg parser
parser = argparse.ArgumentParser(usage='./{0} [--input <input>] [--output <output>] [--branch <branch>] <values_file>'.format(sys.argv[0]))
parser.add_argument('-i', '--input')
parser.add_argument('-o', '--output')
parser.add_argument('-b', '--branch', default='default')
parser.add_argument('values_file')
args = parser.parse_args(sys.argv[1:])

ENV = Environment(loader=FileSystemLoader('./'))

# Get input values and template them if required
with open(args.values_file, 'r') as data:
    urls = dict()
    blob_tags = None
    values = yaml.safe_load(data)

    if 'blob_tags' in values:
        blob_tags = values['blob_tags']

    for alias, url in values['urls'].items():
        urls[alias] = Template(url).render(blob_tags=blob_tags, branch=args.branch)

    template = ENV.get_template(args.values_file)
    fd = StringIO(template.render(blob_tags=blob_tags, urls=urls))
    values = yaml.safe_load(fd)

template = ENV.get_template(args.input)

# Generate output file
with open(args.output, 'w') as output:
  output.write(template.render(values=values))
  output.write('\n')

