# frozen_string_literal: true

# Std Lib
require "logger"

# Extracted from Rails v8.0
require_relative "logger_silence"
require_relative "logger_thread_safe_level"

module ActiveSupport
  class Logger < ::Logger
    include LoggerSilence

    # Returns true if the logger destination matches one of the sources
    #
    #   logger = Logger.new(STDOUT)
    #   ActiveSupport::Logger.logger_outputs_to?(logger, STDOUT)
    #   # => true
    #
    #   logger = Logger.new('/var/log/rails.log')
    #   ActiveSupport::Logger.logger_outputs_to?(logger, '/var/log/rails.log')
    #   # => true
    def self.logger_outputs_to?(logger, *sources)
      # NOTE: This is the only line altered for this gem.
      #       We can't risk this gem loading the vanilla BroadcastLogger via autoload
      #       But we also can't make this gem depend on activesupport/broadcast_logger,
      #         as that would be a circular dependency.
      loggers = if defined?(BroadcastLogger) && logger.is_a?(BroadcastLogger)
        logger.broadcasts
      else
        [logger]
      end

      logdevs = loggers.map { |logger| logger.instance_variable_get(:@logdev) }
      logger_sources = logdevs.filter_map { |logdev| logdev.try(:filename) || logdev.try(:dev) }

      normalize_sources(sources).intersect?(normalize_sources(logger_sources))
    end

    def initialize(*args, **kwargs)
      super
      @formatter ||= SimpleFormatter.new
    end

    # Simple formatter which only displays the message.
    class SimpleFormatter < ::Logger::Formatter
      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        "#{(String === msg) ? msg : msg.inspect}\n"
      end
    end

    private

    def self.normalize_sources(sources)
      sources.map do |source|
        source = source.path if source.respond_to?(:path)
        source = File.realpath(source) if source.is_a?(String) && File.exist?(source)
        source
      end
    end
  end
end
