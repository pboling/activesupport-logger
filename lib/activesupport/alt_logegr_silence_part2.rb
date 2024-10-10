# frozen_string_literal: true

module ActiveSupport
  # Extracted from:
  # https://github.com/rails/rails/blob/8d1ade40dd08feb26240ba6ef7e4bed91f70864a/activesupport/lib/active_support/logger_silence.rb
  # Compare SHA with latest commit to check for changes:
  # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_silence.rb
  # This module only contains the instance methods from LoggerSilence
  module AltLoggerSilencePart2
    extend ActiveSupport::Concern

    # Silences the logger for the duration of the block.
    def silence(severity = Logger::ERROR)
      silencer ? log_at(severity) { yield self } : yield(self)
    end
  end
end
