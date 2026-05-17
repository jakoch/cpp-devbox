
## Generating Pages with Jekyll

### Clean

> bundle exec jekyll clean

## Clean and Rebuild

> bundle exec jekyll clean && bundle exec jekyll build

## Serve Pages in Development Mode (LiveReload)

>  jekyll serve --livereload --incremental --config _config.yml,_dev_config.yml

--livereload:
   Enables the live reload feature on server side (port 35729).
   A small script (livereload.js) is added to your served pages (footer).
   When Jekyll rebuilds the site, it sends a signal through the socket.
   The script in the browser listens for that signal and refreshes the page.
   This is not a timed polling mechanism (aka auto-refresh every 5 seconds),
   but a push notification from the server to the browser!

--incremental:
   Means incremental generation of pages.
   Only changed pages are rebuilt instead of rebuilding the entire site.
   The opposite is a full rebuild, which takes longer.

--config:
   Loads a configuration file.
   When multiple files are specified, settings from later files override
   those from earlier ones.

## Purpose of the _dev_config.yml

- Config value `development: true`:
  The value is used to embed the `livereload.js` script only in development mode.
  The value is false in the main config.
  The include of `livereload.js` happens in the  `_includes/footer.html`
