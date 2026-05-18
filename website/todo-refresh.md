# Website Refresh Plan

## Problem

- The `gh-pages` branch of `jakoch/cpp-devbox` contains only a single `index.md` with
  hardcoded pseudo-content. No version tables, no release history, no interactive
  filtering.
- The release workflow produces version data as **markdown** (not JSON), making it
  unusable for structured consumption.
- A full Jekyll site exists in this workspace (layouts, includes, auto-generated
  release pages, OS/Registry filter tabs, version tables) but is **not deployed**
  to gh-pages.

## Architecture

```
  jekyll-devbox (repo)                        cpp-devbox (repo) main branch
  ─────────────────────                       ────────────────────────────────
  Just the devcontainer runtime:              ALL Jekyll site source:
    .devcontainer/                              /website/
      devcontainer.json                           _layouts/    (templates)
      scripts/                                    _includes/   (partials)
        post-create.sh                            _data/       (version JSONs)
        run.sh                                    assets/      (CSS, images)
    .github/ (CODE_OF_CONDUCT, etc.)              index.md     (homepage)
    .dockerignore                                 Gemfile
    .editorconfig                                 _config.yml
    .gitignore
    LICENSE
    Docker image on GHCR:
    ghcr.io/jakoch/jekyll-devbox:tag

      │                                              │
      │  (used as runtime)                           │  (the source)
      └──────────────┬───────────────────────────────┘
                     │
                     ▼
      publish-docs job (release.yml in cpp-devbox):
        1. Pull ghcr.io/jakoch/jekyll-devbox:tag  →  Ruby + Jekyll runtime
        2. Checkout cpp-devbox                     →  /website source
        3. Overlay version JSON artifacts into /website/_data/
        4. docker run jekyll-devbox bundle exec jekyll build
        5. Push _site/ to gh-pages
```

---

## Chapter A: Changes in the `jakoch/cpp-devbox` repo

### A1. Switch `show-tool-versions.sh` to JSON output in release.yml

The script supports `show-tool-versions.sh json` but is invoked without args.
Change the two `docker run` calls:

```yaml
docker run ... /workspace/show-tool-versions.sh json > versions-${codename}-base.json
docker run ... /workspace/show-tool-versions.sh json > versions-${codename}-with-vulkan.json
```

### A2. Create a per-codename aggregated versions JSON

Merge both variants into a single `versions-${codename}.json`:

```json
{
  "version": "v1.0.18",
  "codename": "bookworm",
  "debian_version": "12",
  "commit": "<sha>",
  "date": "2026-05-17",
  "images": {
    "base": [
      ["GCC 12", "12.2.0"],
      ["Clang 20", "20.1.0"],
      ["cmake", "3.28.1"],
      ["mold", "2.30.0"],
      ["vcpkg", "2025.04.15"]
    ],
    "with-vulkansdk": [
      ["GCC 12", "12.2.0"],
      ["Clang 20", "20.1.0"],
      ["cmake", "3.28.1"],
      ["vulkansdk", "1.4.350.0"],
      ["Mesa", "22.3.6"]
    ]
  }
}
```

Update the artifact upload to include `versions-${codename}.json`.

### A3. Overhaul the `publish-docs` job

Instead of merging READMEs into one flat `index.md`:

1. **Pull the jekyll-devbox Docker image** as the Ruby/Jekyll runtime
   `ghcr.io/jakoch/jekyll-devbox:20260517-sha-360a8e4`

2. **Checkout cpp-devbox** (itself) to get the `/website` directory,
   which contains the full Jekyll site source (layouts, includes, assets,
   data templates, Gemfile, _config.yml).

3. **Overlay the version JSON artifacts** into `/website/_data/`:
   - Merge per-codename `versions-*.json` into per-release files at
     `_data/releases/{version_sanitized}.json`
   - Update `_data/release-tags.json`
   - Update `_data/images.json`

4. **Build inside the jekyll-devbox container**:
   ```yaml
   docker run --rm -v ${{ github.workspace }}/website:/workspace \
     ghcr.io/jakoch/jekyll-devbox:20260517-sha-360a8e4 \
     /bin/zsh -c "bundle install && bundle exec jekyll build"
   ```

5. **Deploy**: Checkout `gh-pages`, clean it, copy `_site/*` into it, commit, push.

### A4. Create the `/website` directory on `main`

Add a `website/` directory to `main` of `cpp-devbox` containing the complete
Jekyll site source — this is the content of the current workspace:

```
website/
  _config.yml               # Jekyll config (title, plugins, page_gen)
  _data/                    # version JSONs (populated by CI)
    images.json
    release-tags.json
    releases/
    project.json
  _includes/                # partials (navbar, footer, toc, etc.)
  _layouts/                 # page templates (default, release, cpp)
  assets/                   # CSS, images
  index.md                  # homepage
  releases/
    index.md                # releases listing
  cpp-quick-links.md
  Gemfile                   # Ruby deps
  Gemfile.lock
```

### A5. Keep the old README-merging logic as fallback

The old `publish-docs` logic can remain commented out until the new approach
is stable.

---

## Chapter B: Jekyll website improvements ✅ (mostly done)

The following have been implemented in this workspace:

| Item | Status |
|---|---|
| Homepage content (quick-start, features, registries) | ✅ |
| Fix default.html latest release ref (`releases[0]` → `release-tags`) | ✅ |
| Fix release.html date (was always showing latest) | ✅ |
| Fix navbar logo path (`project.logo` vs `project['navbar-logo']`) | ✅ |
| Add forky & unstable to TOC body rows | ✅ |
| Fix toggleOsVisibility JS for all 4 OSes | ✅ |
| Update images.json with forky + sid | ✅ |
| Convert release data to flat array format | ✅ |
| Remove empty tags-overview.html | ✅ |
| Exclude dev files from _site | ✅ |
| Filters below "Available Images" heading | ✅ |
| Header column order: sid → forky → trixie → bookworm | ✅ |
| Debian headers with version + codename + status via `<br>` | ✅ |
| Copy button on docker pull commands | ✅ |
| Table striping + hover highlights | ✅ |
| CSS responsive breakpoints | ✅ |
| OS tab active state styling | ✅ |
| Version comparison table (side-by-side all 4 with-vulkansdk) | ✅ |
| Dockerfile improvements (pre-install Jekyll, ruby-dev, UTC, healthcheck, .dockerignore) | ✅ |
| Devcontainer pulls published image directly | ✅ |

### Remaining Chapter B items

- **`_config.yml`** — set `url` and `baseurl` for GH Pages deployment
- **Release page changelog link** — currently points to `href="x"`, wire to
  real GitHub releases URL

---

## Chapter C: The `jekyll-devbox` repo ✅

The repo is live at `github.com/jakoch/jekyll-devbox`. It contains:

- `.devcontainer/` — devcontainer config + scripts (image published to GHCR)
- `.github/` — community files (CODE_OF_CONDUCT, CONTRIBUTING, SECURITY)
- `.dockerignore`, `.editorconfig`, `.gitignore`, `.hadolint.yml`, `LICENSE`

**It does NOT contain Jekyll templates.** The jekyll-devbox repo is purely the
devcontainer runtime environment. All Jekyll site source lives in the
`cpp-devbox` repo under `/website`.

The Docker image `ghcr.io/jakoch/jekyll-devbox:20260517-sha-360a8e4` is used in
two places:
1. **Devcontainer** — `devcontainer.json` references it directly via `image`
2. **CI** — `publish-docs` job pulls it as the Jekyll build runtime

---

## Deployment Flow (Final)

```
release.yml (build job) — in cpp-devbox repo
  │
  ├─ info-{codename}.json
  ├─ versions-{codename}-base.json
  ├─ versions-{codename}-with-vulkan.json
  ├─ SBOMs, attestations...
  │
  ▼  (artifacts)
  │
release.yml (publish-docs job) — in cpp-devbox repo
  │
  ├─ Pull ghcr.io/jakoch/jekyll-devbox:tag     →  Ruby + Jekyll runtime
  ├─ Checkout cpp-devbox (itself)              →  /website source
  ├─ Overlay version JSON artifacts into /website/_data/
  ├─ docker run ... jekyll-devbox bundle exec jekyll build
  ├─ Checkout gh-pages branch, clean it
  ├─ Copy _site/* → gh-pages root
  └─ Commit & push to gh-pages
```
