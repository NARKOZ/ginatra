## master

  * Log warnings and errors. Add a new setting: `log_file` to customize log file
    location.
  * Fix server startup when using Ruby 1.9
  * Upgrade to Twitter Bootstrap 3. Make interface mobile-friendly and
    responsive.
  * Introduce a new setting: `sitename` to customize title.
  * Improve error handling for invalid custom configuration. (@rogermarlow)
  * Your contribution here.

## 4.0.2 (2015-01-15)

  * Ignore files in `git_dirs` by default and remove `ignored_files` setting.
  * Allow non git directories inside `git_dirs`.

## 4.0.1 (2015-01-08)

  * Fix `RACK_ENV` setting in CLI that prevented to properly start Ginatra in
    production mode.

## 4.0.0 Aurora (2015-01-07)

  initial release of 4.x version
