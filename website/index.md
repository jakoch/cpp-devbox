---
layout: default
---

## Quick Start

```bash
docker pull ghcr.io/jakoch/cpp-devbox:bookworm-latest

docker run --rm -it ghcr.io/jakoch/cpp-devbox:bookworm-latest
```

## Features

- **Compilers**: GCC 12–16, Clang 16–22, full LLVM toolchain (clangd, clang-tidy, clang-format, lld, lldb, libc++, libomp, libfuzzer)
- **Build systems**: CMake, Meson, Ninja
- **Package managers**: vcpkg, uv (Python)
- **Linker**: mold (compiled from source with Clang)
- **Caching**: ccache
- **Analysis**: cppcheck, valgrind, gcovr, lcov
- **Profiling & tracing**: perf, gprof, strace, ltrace
- **Assemblers**: nasm, fasm
- **Documentation**: Doxygen, Sphinx
- **Utilities**: zsh + ohmyzsh, git, gh CLI, hyperfine, ripgrep, fd, fzf, jq, nano
- **with-vulkansdk variant adds**: Vulkan SDK + Mesa (lavapipe)

# Releases

This is the list of Github Release tags.

Each tag has container images on [DockerHub](https://hub.docker.com/r/jakoch/cpp-devbox) and [GHCR](https://ghcr.io/jakoch/cpp-devbox).

Each tag has a Debian version (12-bookworm, 13-trixie, 14-forky (testing), sid-unstable) and an image variant (base, with-vulkansdk).

The "with-vulkansdk" image includes Vulkan SDK and Mesa on top of the "base".

Each release page provides:
 - an overview of the software versions included in the image variant,
 - a link to the changelog, and
 - copy-pasteable commands to pull the image from a registry.

{% include releases-list.html %}

## Registries

| Registry                  | URL                                                             |
|---------------------------|-----------------------------------------------------------------|
| GitHub Container Registry | [ghcr.io/jakoch/cpp-devbox](https://ghcr.io/jakoch/cpp-devbox)  |
| Docker Hub                | [jakoch/cpp-devbox](https://hub.docker.com/r/jakoch/cpp-devbox) |

## Image Matrix

| Debian Base | Version | Codename | Variants             |
|-------------|---------|----------|----------------------|
| Unstable    | sid     | unstable | base, with-vulkansdk |
| Testing     | 14      | forky    | base, with-vulkansdk |
| Stable      | 13      | trixie   | base, with-vulkansdk |
| Oldstable   | 12      | bookworm | base, with-vulkansdk |


