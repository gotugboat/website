---
title: "Overview"
description: "Overview"
lead: ""
date: 2023-01-08T20:31:40-05:00
lastmod: 2023-01-08T20:31:40-05:00
draft: false
images: []
menu:
  docs:
    parent: "configuration"
weight: 210
toc: true
---

Tugboat can be configured using a combination of command line flags, environment variables, and a configuration file. This section contains details on what options are available and how to use them.

## Variable Precedence
Configurations are read in the following order, with the top of this list taking priority over the lower portions of the list.

- Command line flags
- Environment variables
- Configuration file settings

## Environment Variables

| Env                                           | Function                                                         |
|-----------------------------------------------|------------------------------------------------------------------|
| `DOCKER_REGISTRY="docker.io"`                 | The docker registry to use                                       |
| `DOCKER_NAMESPACE="namespace"`                | The namespace on the docker registry to use                      |
| `DOCKER_USER="username"`                      | The username credential with access to the registry              |
| `DOCKER_PASS="password"`                      | The password credential with access to the registry              |
| `IMAGE_NAME="tugboat"`                        | The name of the image being built                                |
| `IMAGE_VERSION="v1.0.0"`                      | The version for the image being built                            |
| `IMAGE_SUPPORTED_ARCHITECTURES="amd64,arm64"` | A list of architectures that will be built for this image        |
| `BUILD_ARGS="FOO=bar,BAR=foo"`                | A list of build-time variables in a comma separated string       |
| `BUILD_CONTEXT="."`                           | Docker image build path to use                                   |
| `BUILD_FILE="Dockerfile"`                     | Name of the Dockerfile                                           |
| `BUILD_PUSH=false`                            | Push the image to a container registry after building            |
| `BUILD_PULL=false`                            | Always attempt to pull a newer version of the image              |
| `BUILD_NO_CACHE=false`                        | Do not use cache when building the image                         |
| `BUILD_TAGS="tugboat,tugboat:example"`        | Name of the image and optionally a tag in the 'name:tag' format  |

## Configuration File
In addition to environment variables, Tugboat supports reading configuration from a `tugboat.yaml` or `.tugboat.yaml` file located in one of the following folders:
- The repository's root directory (`tugboat.yaml`)
- The `ci` directory (`ci/tugboat.yaml`)
- The `.ci` directory (`.ci/tugboat.yaml`)

Using the `--config=/path/to/file` option with Tugboat will allow you to choose a specific file if these locations don't suit your needs. Be sure to reference the [variable precedence](#variable-precedence) section above to learn how variables are assigned priority when using a configuration file paired with environment variables.

**Setting `image.version`**

The configuration file allows for some basic usage of bash expressions to set the value. Currently the supported functions include:
- `echo`
- `cat`
- `git`

Here are some examples to use for setting the `image.version` option:
- `v1.0.0`
- `$VERSION`
- `${VERSION}`
- `$(cat VERSION)`
- `$(echo $VALUE)`
- `$(git log -1 --pretty=%h)`

> **Note:** Only commands wrapped in `$()` will be evaluated for substitution. Values that are prefixed by `$` or wrapped in `${}` are loaded as environment variables.

## See also
- [Example file]({{< relref "example-file" >}})
- [Templates]({{< relref "templates" >}})
