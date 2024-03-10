# Changelog

All changes to the project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
The project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- changes

**Added**

- added nano
- added AsciiArt to Dockerfile to utilize the VSCode MiniMap better
- added Trixie Dockerfile into ./devcontainer/debian/trixie

**Changed**

- changed Github Release workflow to build 4 images:
  - bookwork: base + with-vulkan
  - trixie: base + with-vulkan
- moved Bookworm Dockerfile into ./devcontainer/debian/bookworm
- changed Github release workflow file
  - use docker/metadata-action and docker/build-push-action
- removed usages of sudo
- ignore hadolint warning diallowing both curl and wget
- fixed the need to redeclare the VULKAN_VERSION in multiple build stages
  by introducing global build args and reusing them in FROM sections
- reduced number of ENV declarations by using line continuations
- updated Vulkan_SDK to v1.3.275.0

## [1.0.1] - 10-10-2023

**Changed**

- remoteUser is now "root"

**Added**

- integrated all .devcontainer "features" into the Dockerfile
  - added vcpkg
  - added zsh, omyzsh, powerline fonts
  - added zsh plugins: autosuggestions, autocompletions, history search
  - added github cli
  - added cmake latest version
- added libclang-rt-17-dev
- added "created" annotation to container description

**Removed**

- removed the .devcontainer "features" key

## [1.0.0] - 01-10-2023

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


<!-- Backlinks -->

[unreleased]: https://github.com/jakoch/cpp-devbox/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.1
[1.0.0]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.0
