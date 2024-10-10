# frozen_string_literal: true

# Extracted from:
# https://github.com/rails/rails/blob/564e427c05e0d3d24ce8c3ab17ea0969011e056a/activesupport/lib/active_support/logger_thread_safe_level.rb
# Compare SHA with latest commit to check for changes:
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
require_relative "logger_thread_safe_level"

module ActiveSupport
  # Extracted from:
  # https://github.com/rails/rails/blob/8d1ade40dd08feb26240ba6ef7e4bed91f70864a/activesupport/lib/active_support/logger_silence.rb
  # Compare SHA with latest commit to check for changes:
  # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_silence.rb
  # This module only contains the included block from LoggerSilence
  module AltLoggerSilencePart1
    extend ActiveSupport::Concern

    # Thanks to ^ the included block of the original version of the module will not run.
    included do
      cattr_accessor :silencer, default: true
      include ActiveSupport::LoggerThreadSafeLevel
    end
  end
end
