# The Tugboat Website

This repository contains the content used to build the Tugboat website, available at [https://gotugboat.io](https://gotugboat.io).

## Tooling
This website is built using the [Hugo](https://gohugo.io/) static site generator. Instructions for how to install can be found [here](https://gohugo.io/getting-started/installing/).

We are currently managing the nodejs version with [`asdf`](https://asdf-vm.com/). You can find the installation instructions for asdf [here](https://asdf-vm.com/guide/getting-started.html). Once `asdf` has been installed, [install the nodejs plugin](https://github.com/asdf-vm/asdf-nodejs#install) using instructions from their documentation.

## Site Content

The content for the Tugboat documentation is located under the `docs` folder in this repository.

## Run the website locally

### Step 0: Install prerequisites

- Ensure there is a valid installation of `asdf` and `hugo`
- Ensure that you have installed the asdf node plugin

### Step 1: Clone the project

```bash
git clone https://github.com/gotugboat/website.git && cd website
```

### Step 2: Prepare the theme, install npm dependencies and build the site

```bash
make
```

Running `make` will take care of the following:

- Preparing your environment using `asdf` and installing nodejs
- Pulling the [doks](https://getdoks.org/) theme locally
- Generate and building the documentation

### Step 3: Run the site
```bash
hugo serve
```

This command will start the local Hugo server on http://localhost:1313.
