---
layout: default
---

# Releases

cpp-devbox publishes two kinds of builds to
[DockerHub](https://hub.docker.com/r/jakoch/cpp-devbox) and
[GHCR](https://ghcr.io/jakoch/cpp-devbox):

- a **release** for every semantic version tag (`v1.0.19`), tagged
  `<codename>-<version>`, e.g. `jakoch/cpp-devbox:bookworm-1.0.19`. The page of a
  release lists the software versions of every image variant, a side-by-side
  version comparison of all Debian variants, a link to the changelog and
  copy-pasteable pull commands. The software versions are only recorded for the
  build that published the release, so the pages of the older releases show the
  pull commands and the changelog only.
- a **scheduled build** of the `main` branch, every Sunday. The newest of them
  is the rolling build, published under the floating `-latest` tags, e.g.
  `jakoch/cpp-devbox:bookworm-latest`. Every scheduled build is additionally
  tagged with its build date, e.g. `jakoch/cpp-devbox:bookworm-20260920`, which
  pins that build.

{% include releases-list.html %}
