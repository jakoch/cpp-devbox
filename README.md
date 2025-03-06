![jakoch-cpp-devbox](assets/cpp-devbox-repo-card.png)

# C++ DevBox [![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jakoch/cpp-devbox/release.yml?branch=main&style=flat&logo=github&label=Image%20published%20on%20GHCR)](https://github.com/jakoch/cpp-devbox)

A Docker-based development container for C/C++ development.

**Debian Linux 12 Bookworm with LLVM 20 & GCC 12+13, VulkanSDK 1.4.304.1, Mesa, CMake, VCPKG, mold, zsh**

**Debian Linux 13 Trixie with LLVM 20 & GCC 14, VulkanSDK 1.4.304.1, Mesa, CMake, VCPKG, mold, zsh**

## What is this?

This repository maintains Dockerfiles for generating two container images based on two Debian Linux versions.

One image includes GCC and LLVM.

The other image includes GCC, LLVM, and Vulkan SDK with Mesa.

Both images are build using Debian 12 Bookworm and Debian 13 Trixie.

All images are published to the Github Container Registry (GHCR).

The purpose of these images is to setup a C++ development environment within Visual Studio Code using a [devcontainer config](https://github.com/jakoch/cpp-devbox#fetching-the-prebuilt-container-images-using-a-devcontainer-config).

## Images and Sizes

[bookworm-latest]: https://ghcr.io/jakoch/cpp-devbox:bookworm-latest
[trixie-latest]:   https://ghcr.io/jakoch/cpp-devbox:trixie-latest
[bookworm-with-vulkansdk-latest]: https://ghcr.io/jakoch/cpp-devbox:bookworm-with-vulkansdk-latest
[trixie-with-vulkansdk-latest]: https://ghcr.io/jakoch/cpp-devbox:trixie-with-vulkansdk-latest

| ⭣ Version Tag &nbsp;&nbsp; OS ⭢ | Debian 12 - Bookworm | Debian 13 - Trixie |
|-----------------------------------|---------------------------|--------------------|
| Latest | ![bookworm-latest](https://ghcr-badge.egpl.dev/jakoch/cpp-devbox/size?color=%2344cc11&tag=bookworm-latest&label=image+size&trim=) <br> [bookworm-latest] | ![trixie-latest](https://ghcr-badge.egpl.dev/jakoch/cpp-devbox/size?color=%2344cc11&tag=trixie-latest&label=image+size&trim=) <br>[trixie-latest]
| Latest "with-vulkansdk" | ![bookworm-with-vulkansdk-latest](https://ghcr-badge.egpl.dev/jakoch/cpp-devbox/size?color=%2344cc11&tag=bookworm-with-vulkansdk-latest&label=image+size&trim=) <br>[bookworm-with-vulkansdk-latest] |   ![trixie-with-vulkansdk-latest](https://ghcr-badge.egpl.dev/jakoch/cpp-devbox/size?color=%2344cc11&tag=trixie-with-vulkansdk-latest&label=image+size&trim=) <br> [trixie-with-vulkansdk-latest]

You find the [versioning scheme for images below](#versioning-scheme-for-images).

## What is pre-installed?

Here is a basic overview of the pre-installed tools. For details, please refer to the Dockerfiles.

On top of the base image the following tools are installed:

- zsh with plugins: autosuggestions, completions, history substring search
- git, nano, jq
- curl, wget
- cppcheck, ikos, valgrind
- lcov, gcov, gcovr
- strace, ltrace
- perf, gprof
- nasm, fasm
- meson
- CMake (latest version)
- ccache (latest version)
- vcpkg (latest version)
- mold (latest version)
- Doxygen (latest version)
- git, github cli

### [Dockerfile for Debian 12 - Bookworm](https://github.com/jakoch/cpp-devbox/blob/main/.devcontainer/debian/bookworm/Dockerfile) (stable)

The following C/C++ compilers and their toolchains are available:

- LLVM 20.1.0
- GCC 12.2.0
- GCC 13.3.0

### [Dockerfile for Debian 13 - Trixie](https://github.com/jakoch/cpp-devbox/blob/main/.devcontainer/debian/trixie/Dockerfile) (unstable)

The following C/C++ compilers and their toolchains are available:

- LLVM 20.1.0
- GCC 13.3.0
- GCC 14.2.0

### VulkanSDK

The `with-vulkansdk` image additionally contains:

- Vulkan SDK 1.3.296.0
- Mesa 22.3.6 (bookworm), 24.2.8 (trixie)
  - (for software rendering with [LLVMpipe](https://docs.mesa3d.org/drivers/llvmpipe.html))

[What is the latest version of VulkanSDK?](https://vulkan.lunarg.com/sdk/latest.json)

## Prerequisites

You need the following things to run this:

- Docker
- Visual Studio Code

## How to run this?

There are two ways of setting the container up.

Either by building the container image locally or by fetching the prebuilt container image from the Github container registry.

### Building the Container Image locally using VSCode

- **Step 1.** Get the source: clone this repository using git or download the zip

- **Step 2.** In VSCode open the folder in a container (`Remote Containers: Open Folder in Container`):

   This will build the container image (`Starting Dev Container (show log): Building image..`)

   Which takes a while...

   Then, finally...

- **Step 3.**  Enjoy! :sunglasses:

### Fetching the prebuilt container images using Docker

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

### Fetching the prebuilt container images using a .devcontainer config

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

### Fetching the bleeding-edge prebuilt container images

The bleeding-edge container versions are build using Debian 13 - Trixie.

The Trixie base image ships GCC 13.2 and LLVM 16 by default.
For GCC its also the latest available upstream version.
For LLVM we installed the latest available upstream version: LLVM 18.

These images are unstable because:

- a) the Debian base image Trixie itself unstable,
- b) LLVM 18 has package requirements, which can not be resolved with Trixie packages alone, so several Debian SID packages are required.


### Versioning Scheme for Images

The container images use the following versioning scheme.

The base URL for GHCR.io is: `ghcr.io/jakoch/cpp-devbox:{tag}`.

#### Scheduled Builds

The following container tags are created for scheduled builds:

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-{date}}`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-{{date}}`

#### For git push

The following container tags are created only on push, not when tagging:

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-{{date}}-sha-{{sha}}`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-{{date}}-sha-{{sha}}`

#### For git tag

The following container tags are created for git tags:

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-{{ version }}`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-{{ major }}.{{ minor }}`

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-{{ version }}`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-{{ major }}.{{ minor }}`

#### Latest

The container tag "latest" is applied to the latest build:

- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-latest`
- `ghcr.io/jakoch/cpp-devbox:{debian_codename}-with-vulkansdk-latest`
