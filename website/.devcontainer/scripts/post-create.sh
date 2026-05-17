#!/bin/sh

# Install project-specific Ruby gems from Gemfile
if [ -f Gemfile ]; then
    bundle install
fi
