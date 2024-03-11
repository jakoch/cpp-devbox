
# C++ DevBox [![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jakoch/cpp-devbox/release.yml?branch=main&style=flat&logo=github&label=Image%20published%20on%20GHCR)](https://github.com/jakoch/cpp-devbox)

A Docker development box for C/C++.

**Debian Linux 12 Bookworm with LLVM 17 & GCC 13, VulkanSDK 1.3.275.0, CMake, VCPKG, zsh**

**Debian Linux 13 Trixie with LLVM 18 & GCC 13, VulkanSDK 1.3.275.0, CMake, VCPKG, zsh**


## What is this?

This repository maintains Dockerfiles for generating two container images based on two Debian Linux versions.

One image includes GCC and LLVM (container size: ~2GB).

The other image includes GCC, LLVM, and Vulkan SDK (container size: ~4GB).

Both images are build using Debian 12 Bookworm and Debian 13 Trixie.

All images are published to the Github Container Registry (GHCR).

The purpose of these images is to setup a C++ development environment within Visual Studio Code using a [devcontainer config](https://github.com/jakoch/cpp-devbox#fetching-the-prebuild-container-images-using-a-devcontainer-config).

## What is pre-installed?

Here is a basic overview of the pre-installed tools. For details, please refer to the Dockerfiles.

On top of the base image the following tools are installed:

- zsh with plugins: autosuggestions, completions, history substring search
- git, nano, jq
- curl, wget
- cppcheck, valgrind, ccache
- CMake
- vcpkg

### [Dockerfile for Debian 12 - Bookworm](https://github.com/jakoch/cpp-devbox/blob/main/.devcontainer/debian/bookworm/Dockerfile) (stable)

The following C/C++ compilers and their toolchains are available:

- LLVM 17.0.2
- GCC 12.2.0
- GCC 13.2.0

### [Dockerfile for Debian 13 - Trixie](https://github.com/jakoch/cpp-devbox/blob/main/.devcontainer/debian/trixie/Dockerfile) (unstable)

The following C/C++ compilers and their toolchains are available:

- LLVM 18
- GCC 13.2.0

### VulkanSDK

The `with-vulkansdk` image additionally contains:

- Vulkan SDK 1.3.275.0

## Prerequisites

You need the following things to run this:

- Docker
- Visual Studio Code

## How to run this?

There are two ways of setting the container up.

Either by building the container image locally or by fetching the prebuild container image from the Github container registry.

### Building the Container Image locally using VSCode

- **Step 1.** Get the source: clone this repository using git or download the zip

- **Step 2.** In VSCode open the folder in a container (`Remote Containers: Open Folder in Container`):

   This will build the container image (`Starting Dev Container (show log): Building image..`)

   Which takes a while...

   Then, finally...

- **Step 3.**  Enjoy! :sunglasses:

### Fetching the prebuild container images using Docker

This container image is published to the Github Container Registry (GHCR).

You may find the package here: https://github.com/jakoch/cpp-devbox/pkgs/container/cpp-devbox.

**Command Line**

You can install the container image from the command line:

```bash
docker pull ghcr.io/jakoch/cpp-devbox:bookworm-latest
```

For the image containing Vulkan SDK append `with-vulkansdk-latest`:

```bash
docker pull ghcr.io/jakoch/cpp-devbox:bookworm-with-vulkansdk-latest
```

**Dockerfile**

You might also use this container image as a base image in your own `Dockerfile`:

```bash
FROM ghcr.io/jakoch/cpp-devbox:bookworm-latest
```

### Fetching the prebuild container images using a .devcontainer config

**Devcontainer.json**

You might use this container image in the `.devcontainer/devcontainer.json` file of your project:

```json
{
  "name": "My C++ Project DevBox",
  "image": "ghcr.io/jakoch/cpp-devbox:bookworm-latest"
}
```

**Devcontainer.json + with-vulkansdk image**

You might use this container image in the `.devcontainer/devcontainer.json` file of your project:

```json
{
  "name": "My C++ Project DevBox",
  "image": "ghcr.io/jakoch/cpp-devbox:bookworm-with-vulkansdk-latest"
}
```

#### Developer Notes

### Fetching the bleeding-edge prebuild container images

The bleeding-edge container versions are build using Debian 13 - Trixie.

The Trixie base image ships GCC 13.2 and LLVM 16 by default.
For GCC its also the latest available upstream version.
For LLVM we installed the latest available upstream version: LLVM 18.

These images are unstable because:

- a) the Debian base image Trixie itself unstable,
- b) LLVM 18 has package requirements, which can not be resolved with Trixie packages alone, so several Debian SID packages are required.


### Versioning Scheme for Images

The container images use the following versioning schemes.

#### Scheduled

The following container tags are created for scheduled builds:

- `ghcr.io/jakoch/cpp-devbox:{DEBIAN_CODENAME}-nightly-DATE-latest`
- `ghcr.io/jakoch/cpp-devbox:{DEBIAN_CODENAME-with-vulkansdk-nightly-DATE-latest`

#### For git push

The following container tags are created only on push, not when tagging:

- `ghcr.io/jakoch/cpp-devbox:{DEBIAN_CODENAME}-latest`
- `ghcr.io/jakoch/cpp-devbox:{DEBIAN_CODENAME}-{DATE}-sha-{SHA}`

- `ghcr.io/jakoch/cpp-devbox:{DEBIAN_CODENAME}-with-vulkansdk-latest`
- `ghcr.io/jakoch/cpp-devbox:{DEBIAN_CODENAME}-with-vulkansdk--{DATE}-sha-{SHA}`

#### For git tag

The following container tags are created for git tags:

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-1.0.0`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-1.0`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-latest`

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-1.0.0`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-1.0`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-latest`
