# frozen_string_literal: true

module ActiveSupport
  # Extracted from:
  # https://github.com/rails/rails/blob/564e427c05e0d3d24ce8c3ab17ea0969011e056a/activesupport/lib/active_support/logger_thread_safe_level.rb
  # Compare SHA with latest commit to check for changes:
  # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/logger_thread_safe_level.rb
  module LoggerThreadSafeLevel # :nodoc:
    extend ActiveSupport::Concern

    def local_level
      IsolatedExecutionState[local_level_key]
    end

    def local_level=(level)
      case level
      when Integer
      when Symbol
        level = Logger::Severity.const_get(level.to_s.upcase)
      when nil
      else
        raise ArgumentError, "Invalid log level: #{level.inspect}"
      end
      if level.nil?
        IsolatedExecutionState.delete(local_level_key)
      else
        IsolatedExecutionState[local_level_key] = level
      end
    end

    def level
      local_level || super
    end

    # Change the thread-local level for the duration of the given block.
    def log_at(level)
      old_local_level, self.local_level = local_level, level
      yield
    ensure
      self.local_level = old_local_level
    end

    private

    def local_level_key
      @local_level_key ||= :"logger_thread_safe_level_#{object_id}"
    end
  end
end
