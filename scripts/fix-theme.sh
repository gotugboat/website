#!/bin/bash

filename="themes/doks/package.json"

# Replace content on line 37 (postinstall)
if ! sed -i '' '37s/.*//' 2>/dev/null $filename; then
  if ! sed -i '37s/.*//' $filename; then
    exit 1
  fi
fi
