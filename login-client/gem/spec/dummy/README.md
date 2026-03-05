# Dummy Rails Application

This is a minimal Rails application used exclusively as a test harness for the `muni-login-client` gem.

The gem depends on Rails components (ActiveSupport, ActiveRecord, ActionPack) and expects a Rails environment at runtime. The dummy app provides that environment so RSpec can boot Rails, load the gem, and exercise its code against a real (SQLite) database and request stack.

This app is **not** deployed anywhere. It exists only to support `bundle exec rspec`.

## How Ruby and Rails versions are chosen

The dummy app does **not** have its own Gemfile. The dependency chain works like this:

1. **Ruby version** — set by `.ruby-version` (currently `3.1.3`), present both at the gem root (`gem/.ruby-version`) and here (`spec/dummy/.ruby-version`). The Docker build also defaults to this version via `ARG RUBY_VERSION=3.1.3` in `login-client/Dockerfile`.

2. **Rails version** — determined entirely by the gemspec. The gem root's `Gemfile` contains only `source` + `gemspec`, so Bundler resolves Rails from the `add_development_dependency 'rails'` line in `muni-login-client.gemspec`. Whatever version Bundler picks is the Rails version the dummy app boots.

3. **Rails defaults** — `config/application.rb` calls `config.load_defaults 6.1`, which controls framework default settings but does **not** pin the Rails version. This value should be updated if the minimum supported Rails version changes.

In short: change the gemspec to change the Rails version used in tests; change `.ruby-version` (and the Dockerfile `ARG`) to change the Ruby version.

## References

- https://lokalise.com/blog/how-to-create-a-ruby-gem-testing-suite/#Adding_development_dependencies
