---
layout: default
---

cpp-devbox streamlines the setup of a complete C++ development stack in standardized and portable Docker containers. It provides compilers, build systems, debuggers, and analysis tools — optimized for modern C++ projects on Linux, VSCode devcontainers, and CI/CD pipelines.

## Quick Start

```bash
docker pull ghcr.io/jakoch/cpp-devbox:bookworm-latest

docker run --rm -it ghcr.io/jakoch/cpp-devbox:bookworm-latest
```

## Technical Base and Images

### Distributions

This repository provides Dockerfiles for building container images based on Debian Linux.

We offer images for:

- Debian 12 (Bookworm, oldstable),
- Debian 13 (Trixie, stable),
- Debian 14 (Forky, testing) and
- Debian SID (unstable).

### Container Images

There are two main variants per distribution: one with the standard toolchain
and one with an additional Vulkan SDK and Mesa for graphics development.

- **base:** Includes GCC and LLVM.
- **with-vulkansdk:** Includes GCC, LLVM, and additionally the Vulkan SDK with Mesa.

### Image Matrix

| Debian Base | Version | Codename | Variants             |
|-------------|---------|----------|----------------------|
| unstable    | sid     | unstable | base, with-vulkansdk |
| testing     | 14      | forky    | base, with-vulkansdk |
| stable      | 13      | trixie   | base, with-vulkansdk |
| oldstable   | 12      | bookworm | base, with-vulkansdk |

## Container Registries

The images are automatically published to Github Container Registry (GHCR) and
the Docker Hub (hub.docker.com) upon updates.

For a complete list of C++ related tools, see [What is pre-installed?](#what-is-pre-installed).

| Registry                  | URL                                                             |
|---------------------------|-----------------------------------------------------------------|
| GitHub Container Registry | [ghcr.io/jakoch/cpp-devbox](https://ghcr.io/jakoch/cpp-devbox)  |
| Docker Hub                | [jakoch/cpp-devbox](https://hub.docker.com/r/jakoch/cpp-devbox) |

## What is pre-installed?

The image includes GCC v12–v16, Clang v16–v22 (full LLVM toolchain), CMake, Meson, Ninja, vcpkg, mold, and many more. The **with-vulkansdk** variant additionally includes the Vulkan SDK and Mesa.

See the [releases page](/releases/) for exact tool versions per release, or the [Version Comparison](/releases/#version-comparison) for a side-by-side view across Debian variants.

## Usage

For detailed setup instructions — including building locally, devcontainer configuration, CI/CD usage, and version pinning — see the [GitHub README](https://github.com/jakoch/cpp-devbox).

