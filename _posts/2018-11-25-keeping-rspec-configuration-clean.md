---
title: Keeping RSpec configuration clean
---

Keeping everything in `spec_helper.rb` and `rails_helper.rb` will quickly get messy.
A cleaner, modular pattern is needed.

This is inspired by Artur Trzop's [article](https://docs.knapsackpro.com/2018/clean-rspec-configuration-directory-structure-for-ruby-on-rails-gems-needed-in-testing).


**Rule 0**: modularity and explicitness[^explicitness] are the highest priorities.

**Rule 1**: configurations of auxiliary gems (e.g. `database_cleaner`, `factory_bot`, `vcr` etc.) all live in separate files inside `spec/support/config`. Here is a template:

```ruby
# spec/support/config/my_gem.rb

require 'my_gem' # if `require: false` in Gemfile

# Insert here MyGem specific configuration.

# If necessary, hook MyGem into RSpec:
RSpec.configure do |config|
  # ...
end
```

**Rule 2a**: `spec/spec_helper.rb` is the configuration entry point for tests that *do not* need `rails`:

```ruby
# spec/spec_helper.rb

# Explicitly require configurations for auxiliary gems you need.
require 'support/config/my_gem'

RSpec.configure do |config|
  # Insert vanilla RSpec configuration here.
end
```

**Rule 2b**: `spec/rails_helper.rb` is the configuration entry point for tests that *do* need `rails`.

```ruby
# spec/rails_helper.rb

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Explicitly require configurations for auxiliary gems you need.
require "support/config/my_gem"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Insert Rails related RSpec configuration here.
end
```

**Note**: separate entrypoints exist in order to speed up tests when possible by avoiding Rails' heavy dependency. If the project is very small, one might be better off with a simple `.rspec`:

```bash
--require spec_helper --require rails_helper
```

[^explicitness]: I'm against doing stuff like `Dir['spec/support/**/*.rb')].each { |f| require f }`.