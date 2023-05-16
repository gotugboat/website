---
title: "Introduction"
description: "Tugboat is an open source automation tool for building multi-arch containers."
lead: "Tugboat is an open source automation tool for building multi-arch containers."
date: 2023-01-08T20:31:40-05:00
lastmod: 2023-01-08T20:31:40-05:00
draft: false
images: []
menu:
  docs:
    parent: "getting-started"
weight: 100
toc: true
---

## Background

Creating a docker image that has an image manifest takes many commands to do manually. Because manual processes
are error prone and tedious to carry out, many of us tend to create helper scripts that do these processes for us
to some degree. When it comes to containers, many times these scripts will only work for the single project that you
are currently building out and then make new scripts for other projects later down the line.

Tugboat was created so that building multi-arch images is easy by using a repeatable configuration file that can be
stored with your code base. Using this configuration file would allow you to retire your homegrown scripts in favor
of a different and simpler approach.

## Usage

Tugboat was built keeping the idea of continuous integration in mind. So this means that publishing your images can be
controlled using the `tugboat.yaml` file. Since this file is stored in your project repository along side your code, it
can be implemented into your already existing CI/CD build processes or help you start a CI/CD process all together.

This website contains documentation pages aimed at helping you get up and running quickly so that you can begin to build
your multi-arch capable images using Tugboat today!

Contributions are welcomed, so feel free to [create an issue](https://github.com/gotugboat/website/issues) or open a
[GitHub pull request](https://github.com/gotugboat/website/pulls) if you find that something is not clear or that you feel
something could be presented in a better way.
