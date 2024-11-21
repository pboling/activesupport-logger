# Ruby stdlib
require "logger"

# External libraries
require "active_support/version"
require "version_gem"
require "backports/3.1.0/array/intersect"

# This library
require_relative "activesupport/logger/version"

# Original from whatever version of Rails / ActiveSupport is loaded...
require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"

# !!ORDER MATTERS!!
#
# Extracted from:
#
# Compare SHA with latest commit to check for changes:
# https://github.com/rails/rails/blob/main/activesupport/test/isolated_execution_state_test.rb
# Compare SHA with latest commit to check for changes:
# https://github.com/rails/rails/blob/540d2f41f6913cd6c5a71301540bfe1551c2acc5/activesupport/test/isolated_execution_state_test.rb
require_relative "activesupport/isolated_execution_state"

#
# Extracted from:
# https://github.com/rails/rails/blob/564e427c05e0d3d24ce8c3ab17ea0969011e056a/activesupport/lib/active_support/logger_thread_safe_level.rb
# Compare SHA with latest commit to check for changes:
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
require_relative "activesupport/logger_thread_safe_level"

# Extracted from:
# https://github.com/rails/rails/blob/8d1ade40dd08feb26240ba6ef7e4bed91f70864a/activesupport/lib/active_support/logger_silence.rb
# Compare SHA with latest commit to check for changes:
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
require_relative "activesupport/logger_silence"

# Extracted from:
# https://github.com/rails/rails/blob/fc62f03ae30fbb9108b004daa9bfedef0401003f/activesupport/lib/active_support/logger.rb
# Compare SHA with latest commit to check for changes:
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger.rb
require_relative "activesupport/logger"

# Namespace for the Version of this gem (and nothing else)
module Activesupport
end

Activesupport::Logger::Version.class_eval do
  extend VersionGem::Basic
end
