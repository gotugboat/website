---
title: "Quick Start"
description: "Quickly learn how to create a multi-arch image with Tugboat."
lead: "Learn how to create a multi-arch image."
date: 2023-01-08T20:31:40-05:00
lastmod: 2023-01-08T20:31:40-05:00
draft: false
images: []
menu:
  docs:
    parent: "getting-started"
weight: 120
toc: true
---

## Prerequisites
- An installation of [Docker Engine](https://docs.docker.com/engine/install/)

## Install the latest version of Tugboat

Use the provided bash installation script to install the latest version of Tugboat.

```bash
curl -sSL https://get.gotugboat.io | bash
```

> **Note:** For all installation options visit the [install documentation]({{< relref "installation" >}})

## Build an image

The following example will build and push the image to DockerHub. This step should be done on a machine of each architecture that you wish to support. The following example assumes you are building on an amd64 system.

```bash
tugboat build -t gotugboat/my-image:v1.0.0 --push
```

Resulting image:
- `docker.io/gotugboat/my-image:amd64-v1.0.0`

## Tag an image

With a built image pushed onto the registry, we can give it additional reference tags. Utilizing the `--push` flag, like in
this example, will push the locally generated tags to your remote registry after they are created.

```bash
tugboat tag gotugboat/my-image --tags latest --architectures amd64,arm64 --push
```

Resulting tags:
- `docker.io/gotugboat/my-image:amd64-latest`
- `docker.io/gotugboat/my-image:arm64-latest`

> **Note:** This assumes that you ran the `tugboat build` command on both an amd64 and arm64 system.

## Create the manifests

Tugboat creates all images with an architecture prepended to the given tag. This is how tugboat knows which image to pull when generating the manifests for your given tags.

<!-- Can we read the registry to see what tags have the arch in it? -->

```bash
tugboat manifest create gotugboat/my-image --for v1.0.0,latest --architectures amd64,arm64 --push
```

Resulting manifests lists:
- `docker.io/gotugboat/my-image:v1.0.0`
  - `docker.io/gotugboat/my-image:amd64-v1.0.0`
  - `docker.io/gotugboat/my-image:arm64-v1.0.0`
- `docker.io/gotugboat/my-image:latest`
  - `docker.io/gotugboat/my-image:amd64-latest`
  - `docker.io/gotugboat/my-image:arm64-latest`

## See also
- [tugboat build]({{< ref "/docs/cli/tugboat-build" >}})
- [tugboat tag]({{< ref "/docs/cli/tugboat-build" >}})
- [tugboat manifest]({{< ref "/docs/cli/tugboat-build" >}})
