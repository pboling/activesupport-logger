# Loading "active_support" normally here ensures this library will work,
#   even if loaded after the vanilla ActiveSupport.
# Unfortunately, it also results in 0% code coverage, because this gem gets loaded too early.
# require "active_support"

# External Deps
require "minitest"
require "test-unit"
require "rspec/pending_for"
require "active_support/core_ext/enumerable"

# Extensions of test-unit
require "active_support/testing/assertions"

# RSpec Configs
require_relative "config/byebug"
require_relative "config/rspec/rspec_block_is_expected"
require_relative "config/rspec/rspec_core"
require_relative "config/rspec/version_gem"
require_relative "config/testing_assertions"
require_relative "support/helpers/multibyte_test_helpers"

# Last thing before loading this gem is to set up code coverage
begin
  # This does not require "simplecov", but
  require "kettle-soup-cover"
  #   this next line has a side effect of running `.simplecov`
  require "simplecov" if defined?(Kettle::Soup::Cover) && Kettle::Soup::Cover::DO_COV
rescue LoadError
  nil
end

# This library
require "activesupport-logger"

# The sibling extracted gem is needed because Rails' tests for active_support/logger depend on the active_support/broadcast_logger
# We have to load it after the gem-under-test because it depends on the gem-under-test (a circular-dev-runtime-dep)
require "activesupport-broadcast_logger"
