---
title: "Templates"
description: ""
lead: ""
date: 2023-01-08T20:31:40-05:00
lastmod: 2023-01-08T20:31:40-05:00
draft: false
images: []
menu:
  docs:
    parent: "configuration"
weight: 240
toc: true
---

## About

Many of the input fields for the CLI support using template strings. This allows Tugboat input options to be evaluated dynamically when working with an image.

## Template Keys

The following table of values are available to call.

| Key                | Description                                                      |
|--------------------|------------------------------------------------------------------|
| `.ImageName`       | The value from `image.name`                                      |
| `.Version`         | The value derived from `image.version`                           |
| `.ShortCommit`     | The git commit short hash                                        |
| `.FullCommit`      | The git commit full hash                                         |
| `.Branch`          | The current git branch                                           |
| `.Tag`             | The current git tag                                              |

## Image Tagging

Image tagging can be defined dynamically using templates in the the configuration file. The `build.tags` option can be defined using supported template fields. 

Given the following `tugboat.yaml` file for example:
```yaml
image:
  name: gotugboat/my-image
  version: v1.0.0
build:
  tags:
    - '{{.ImageName}}:{{.Version}}'
```

The resulting image generated from running `tugboat build` would be `docker.io/gotugboat/my-image:amd64-v1.0.0`.
