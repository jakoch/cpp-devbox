
# C++ DevBox [![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jakoch/cpp-devbox/release.yml?branch=main&style=flat&logo=github&label=Image%20published%20on%20GHCR)](https://github.com/jakoch/cpp-devbox)

A Docker development box for C/C++.

#### What is this?

This is a Docker container based on Debian Linux (see [Dockerfile](https://github.com/jakoch/cpp-devbox/blob/main/.devcontainer/Dockerfile)).

It sets up a C++ development environment for Visual Studio Code.

The repo releases 2 images: one with GCC+LLVM (~2GB) and one with Vulkan SDK on-top (~4GB).

#### What is pre-installed?

Base: Debian 12 - Bookworm

On top of the base image the following tools are installed:
- zsh, git, nano, jq
- curl, wget
- cppcheck, valgrind, ccache
- CMake
- vcpkg

The following C/C++ compilers and their toolchains are available:
 - LLVM v17
 - GCC v12

The `with-vulkansdk` image additionally contains:
 - Vulkan SDK

#### Prerequisites

You need the following things to run this:

- Docker
- Visual Studio Code

#### How to run this?

There are two ways of setting the container up.

Either by building the container image locally or by fetching the prebuild container image from the Github container registry.

##### Building the Container Image locally using VSCode

1. Get the source: clone this repository using git or download the zip
2. In VSCode open the folder in a container (`Remote Containers: Open Folder in Container`):

   This will build the container image (`Starting Dev Container (show log): Building image..`)

   Which takes a while...

   Then, finally...
3. Enjoy! :sunglasses:

##### Fetching the prebuild container images

This container image is published to the Github Container Registry (GHCR).

You may find the package here: https://github.com/jakoch/cpp-devbox/pkgs/container/cpp-devbox.

**Command Line**

You can install the container image from the command line:
```
docker pull ghcr.io/jakoch/cpp-devbox:latest
```

For the image containing Vulkan SDK append `with-vulkansdk-latest`:

```
docker pull ghcr.io/jakoch/cpp-devbox:with-vulkansdk-latest
```

**Dockerfile**

You might also use this container image as a base image in your own `Dockerfile`:
```
FROM ghcr.io/jakoch/cpp-devbox:latest
```

**Devcontainer.json**

You might use this container image in the `.devcontainer/devcontainer.json` file of your project:
```
{
  "name": "My C++ Project DevBox",
  "image": "ghcr.io/jakoch/cpp-devbox:latest"
}
```

**Devcontainer.json + with-vulkansdk image**

You might use this container image in the `.devcontainer/devcontainer.json` file of your project:
```
{
  "name": "My C++ Project DevBox",
  "image": "ghcr.io/jakoch/cpp-devbox:with-vulkansdk-latest"
}
```
