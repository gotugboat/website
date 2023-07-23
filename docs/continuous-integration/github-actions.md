---
title: "GitHub Actions"
description: "GiHub Actions"
lead: ""
date: 2023-01-08T20:31:40-05:00
lastmod: 2023-01-08T20:31:40-05:00
draft: false
images: []
menu:
  docs:
    parent: "continuous-integration"
weight: 410
toc: true
---

Since GitHub currently does not offer arm64 hosted-runners, you will need to set up your own self-hosted runners following the guidelines provided in GitHub's documentation. To create a multi-arch image using a GitHub actions workflow, you can begin with the following example workflow provided below.

## Example workflow


The example workflow consists of three jobs: `Build`, `Tag-Images`, and `Manifest`. Upon triggering the workflow, your image will be built for both amd64 and arm64 architectures. Tugboat will also generate an image manifest for the `1.0.0` and `latest` tags, ensuring your image is available for each architecture.

```yaml
name: CI

on:
  push:
    tags:
      - "v*.*.*"

env:
  REGISTRY_USER: ${{ secrets.REGISTRY_USER }}
  REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
  VERSION: 1.0.0

jobs:
  Build:
    strategy:
      matrix:
        arch: [x64, arm64]
    runs-on: [self-hosted, linux, '${{ matrix.arch }}']
    steps:
      - name: Checkout repository code
        uses: actions/checkout@v3

      - name: Build
        run: |
          tugboat build -t {{.ImageName}}:{{.Version}} --push
  
  Tag-Images:
    needs:
      - Build
    runs-on: [self-hosted, linux, x64]
    steps:
      - name: Checkout repository code
        uses: actions/checkout@v3

      - name: Tag Images
        run: |
          tugboat tag {{.ImageName}}:{{.Version}} --tags latest --architectures amd64,arm64 --push
  
  Manifest:
    needs:
      - Tag-Images
    runs-on: [self-hosted, linux, x64]
    steps:
      - name: Checkout repository code
        uses: actions/checkout@v3

      - name: Create Manifests
        run: |
          tugboat manifest create {{.ImageName}} --for {{.Version}} --latest --architectures amd64,arm64 --push

```

> **Note:** This example assumes that you have pre-installed Tugboat onto the self-hosted runner.

If Tugboat is not pre-installed on your self-hosted runners, you can add a step to install it with the following run command:

```yaml
- name: Install Tugboat
  run: |
    curl -sSL https://get.gotugboat.io | bash
    tugboat --version
```
