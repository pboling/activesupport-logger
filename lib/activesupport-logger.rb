# Ruby stdlib
require "logger"

# External libraries
require "active_support/version"
require "version_gem"

# This library
require_relative "activesupport/logger/version"

# This gem doesn't do anything unless Rails is < v8
if ActiveSupport.version < "8"
  # Loads supporting features from Rails v5, 6, or 7
  require "active_support/concern"
  require "active_support/core_ext/module/attribute_accessors"

  # Require the original tagged logging from whatever version of Rails is loaded,
  #   so that it will be properly monkey patched.
  require "active_support/logger"

  # !!ORDER MATTERS!!
  #
  # Extracted from:
  # https://github.com/rails/rails/blob/564e427c05e0d3d24ce8c3ab17ea0969011e056a/activesupport/lib/active_support/logger_thread_safe_level.rb
  # Compare SHA with latest commit to check for changes:
  # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
  # This is a straightforward monkey patch.
  require_relative "activesupport/logger_thread_safe_level"

  # Extracted from:
  # https://github.com/rails/rails/blob/8d1ade40dd08feb26240ba6ef7e4bed91f70864a/activesupport/lib/active_support/logger_silence.rb
  # Compare SHA with latest commit to check for changes:
  # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
  # This is a straightforward monkey patch.  We can't use part 1,
  #   because it has the `included' block, which can't be monkey patched at all.
  require_relative "activesupport/alt_logegr_silence_part2"

  # Extracted from:
  # https://github.com/rails/rails/blob/fc62f03ae30fbb9108b004daa9bfedef0401003f/activesupport/lib/active_support/logger.rb
  # Compare SHA with latest commit to check for changes:
  # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
  #
  # All this reloading might print warnings about redefined methods, and this is expected.
  # Technically it might even break things, but we don't expect it to, and YMMV.
  require_relative "activesupport/logger"
else
  # Fallback to the original
  require "active_support/logger"
end

# Namespace for the Version of this gem (and nothing else)
module Activesupport
end

Activesupport::Logger::Version.class_eval do
  extend VersionGem::Basic
end
