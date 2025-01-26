# Changelog

All changes to the project will be documented in this file.

- The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
- The date format is YYYY-MM-DD.
- The upcoming release version is named `vNext` and links to the changes between latest version tag and git HEAD.

## [vNext] - unreleased

- "It was a bright day in April, and the clocks were striking thirteen." - 1984

## [1.0.7] - 2025-01-26

**Changed**
- fixed installation "fonts-powerline" by switching from direct download to apt-get

## [1.0.6] - 2024-12-26

**Added**
- added linux-perf, strace, ltrace, meson, nasm, fasm, ikos (static analyzer)
- added spellchecker (streetsidesoftware.vscode-spellchecker as vscode extension)
- added spellchecker configuration. the main config is '/cspell.json', which
  points to '/build-tools/cspell/cspell.config.json'.
- added whitelist for spell checking: '/build-tools/cspell/repo-words.txt'

**Changed**
- bookworm & trixie images: updated VulkanSDK to 1.3.296.0
- bookworm image: updated LLVM to 19
- updated show-tool-versions.sh and show-tool-locations.sh
- CURL_OPTIONS cleanup, removed CURL_OPTIONS_BAR
- instead "-y" use "--assume-yes" on apt-get
- silence warning "debconf: delaying package configuration, since apt-utils is not installed"
  by using ENV DEBCONF_NOWARNINGS="yes"

## [1.0.5] - 2024-07-09

**Added**
- added doxygen (latest binary)
- added python3-sphinx, python3-sphinx-rtd-theme
- added lcov
- trixie image: added gcc-14 (from distribution)
- both with-vulkansdk images: added mesa-vulkan-drivers (for software rendering using llvmpipe)

**Changed**
- bookworm image: updated gcc to 13.3.0
- cleanup mold setup
- tools are symlinked into /usr/bin instead of /usr/local/bin
- updated scripts (show-tool-version/show-tool-locations) to output markdown
- changed workflow file to upload version data as release artefact for every image

## [1.0.4] - 2024-07-04

**Changed**

- changed versioning scheme
  - removed "nightly-" from scheduled builds; its now date only
- ccache: switched from distribution provided ccache to latest version from github
- switched to SPDX-FileCopyrightText on copyright lines

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
- ignore hadolint warning disallowing both curl and wget
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

[vNext]: https://github.com/jakoch/cpp-devbox/compare/v1.0.7...HEAD
[1.0.6]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.7
[1.0.6]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.6
[1.0.5]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.5
[1.0.4]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.4
[1.0.3]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.3
[1.0.2]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.2
[1.0.1]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.1
[1.0.0]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.0
