# Changelog

All changes to the project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
The date format in this file is `YYYY-MM-DD`.
The upcomming release version is named `vNext` and links to the changes between latest version tag and git HEAD.

## [vNext] - unreleased

- "It was a bright day in April, and the clocks were striking thirteen." - 1984

## [1.0.3] - 2024-05-23

**Added**

- added mold linker

**Changed**

- changed Github Release workflow to build 4 images:
  - bookwork: base + with-vulkan
  - trixie: base + with-vulkan
- changed versioning scheme
- updated Vulkan_SDK to v1.3.283.0

## [1.0.2] - 2024-02-15

**Added**

- added nano
- added AsciiArt to Dockerfile to utilize the VSCode MiniMap better
- added Trixie Dockerfile into ./devcontainer/debian/trixie

**Changed**

- moved Bookworm Dockerfile into ./devcontainer/debian/bookworm
- changed Github release workflow file
  - use docker/metadata-action and docker/build-push-action
- removed usages of sudo
- ignore hadolint warning diallowing both curl and wget
- fixed the need to redeclare the VULKAN_VERSION in multiple build stages
  by introducing global build args and reusing them in FROM sections
- reduced number of ENV declarations by using line continuations
- updated Vulkan_SDK to v1.3.275.0

## [1.0.1] - 2023-10-09

**Added**

- integrated all .devcontainer "features" into the Dockerfile
  - added vcpkg
  - added zsh, omyzsh, powerline fonts
  - added zsh plugins: autosuggestions, autocompletions, history search
  - added github cli
  - added cmake latest version
- added libclang-rt-17-dev
- added "created" annotation to container description

**Changed**

- remoteUser is now "root"

**Removed**

- removed the .devcontainer "features" key

## [1.0.0] - 2023-10-01

**Added**

- added devcontainer feature: github-cli, zsh-plugins
- integrated zsh-plugins: git, autosuggestions, autocompletions
- vscode extensions: editorconfig, test-adapter for catch2 and test-explorer
- added container labels
- integrated Vulkan SDK
- added 2 docker stages: cpp-devbox-base and cpp-devbox-with-vulkansdk
- changed workflow to publish 2 images
- added libfuzzer-dev
- added GCC 13.2.0

**Changed**

- german locale "de_DE.UTF-8" is installed and configured, but the default locale is set to "en_US.UTF-8".
- small fixes to show-tool-versions.sh
- Dockerfile: uses ARGS for DEBIAN_VERSION, DEBIAN_VERSION_NAME, LLVM_VERSION, GCC_VERSION

**Removed**

- cmake.configureSetting - CMAKE_EXPORT_COMPILE_COMMANDS ON (you may set this in your project presets)

<!-- Section for Reference Links -->

[vNext]: https://github.com/jakoch/cpp-devbox/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.3
[1.0.2]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.2
[1.0.1]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.1
[1.0.0]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.0
