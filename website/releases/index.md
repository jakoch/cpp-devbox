---
layout: default
---

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