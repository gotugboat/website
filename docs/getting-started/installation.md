---
title: "Installation"
description: "Installation instructions."
lead: ""
date: 2023-01-08T20:31:40-05:00
lastmod: 2023-01-08T20:31:40-05:00
draft: false
images: []
menu:
  docs:
    parent: "getting-started"
weight: 110
toc: true
---

Tugboat is available as a downloadable binary from the [releases page](https://github.com/gotugboat/tugboat/releases) or by running a bash script.

## Bash Script

We provide an installation script that will automatically find and install the latest version of Tugboat.

You can fetch that script, and then execute it locally or install it directly. It is well documented so that you can read through and understand what it's doing before you run it.

Install the latest version of Tugboat with the following command:
```bash
curl -sSL https://get.gotugboat.io | bash
```

*Additional installation options:*

{{< details "Install a specific version of Tugboat" >}}
```bash
curl -sSL https://get.gotugboat.io | TUGBOAT_VERSION=__TUGBOAT_VERSION__ bash
```
{{< /details >}}

{{< details "Install using the script remotely with args and/or options" >}}
```bash
curl -sSL https://get.gotugboat.io | bash -s -- --version __TUGBOAT_VERSION__ --debug
```
{{< /details >}}

{{< details "Download the installation script locally and execute" >}}
```bash
curl -sSL -o install.sh https://get.gotugboat.io \
  && chmod +x install.sh
```
{{< /details >}}

<!-- && curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.1.13 python - -->

## Manually

Tugboat can also be installed manually by following these instructions.

1\. Download the binary with the following command

```bash
curl -Lo "tugboat.tar.gz" "https://github.com/gotugboat/tugboat/releases/download/__TUGBOAT_VERSION__/tugboat-$OS-$ARCH.tar.gz"
```

> **Note:** Ensure the downloaded binary matches your operating system and architecture. Tugboat releases binaries for `darwin` and `linux` on the `amd64`, `arm64`, and `arm` architectures.

2\. Validate the file (optional)

Download the Tugboat checksum file:
```bash
curl -Lo "tugboat.tar.gz.sha256sum" "https://github.com/gotugboat/tugboat/releases/download/__TUGBOAT_VERSION__/tugboat-$OS-$ARCH.tar.gz.sha256sum"
```
> **Note:** Download the same version of the binary and checksum.

Validate the download using the checksum file, run the following command:

```bash
echo "$(<tugboat.tar.gz.sha256sum) tugboat.tar.gz" | sha256sum --check
```

If valid, the output will be:
```
tugboat.tar.gz: OK
```

If the check fails, sha256 exits with nonzero status and prints output similar to:
```
tugboat.tar.gz: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```

3\. Extract the executable from the download
```bash
tar -xzvf tugboat.tar.gz
```

4\. Move the executable to an install location
```bash
mv tugboat/tugboat /usr/local/bin/
```
> **Note:** sudo may be required on some operating systems

5\. Validate the installation
```bash
tugboat --version
```

## See also
- [Quick Start]({{< relref "quick-start" >}})
- [Configuration]({{< ref "docs/configuration/overview" >}})
