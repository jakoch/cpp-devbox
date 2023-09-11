# Changelog

All changes to the project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
The project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

**Added**

- added devcontainer feature: github-cli, zsh-plugins
- integrated zsh-plugins: git, autosuggestions, autocompletions
- vscode extensions: editorconfig, test-adapter for catch2 and test-explorer
- added container labels

**Changed**

- german locale "de_DE.UTF-8" is installed and configured, but the default locale is set to "en_US.UTF-8".
- small fixes to show-tool-versions.sh
- Dockerfile: uses ARGS for DEBIAN_VERSION, DEBIAN_VERSION_NAME, LLVM_VERSION, GCC_VERSION

**Removed**

- cmake.configureSetting - CMAKE_EXPORT_COMPILE_COMMANDS ON (you may set this in your project presets)


## [1.0.0] - tba

<!-- Backlinks -->

[unreleased]: https://github.com/jakoch/cpp-devbox/compare/v1.2.0...HEAD
[1.0.0]: https://github.com/jakoch/cpp-devbox/releases/tag/v1.0.0
