# frozen_string_literal: true

require "stringio"
require "fileutils"
require "tempfile"
require "tmpdir"
require "concurrent/atomics"

require "active_support/core_ext/object/try"

RSpec.describe Activesupport::Logger do
  it "is not a Activesupport::Logger" do
    expect(described_class < Logger).to be_nil
  end
end

RSpec.describe ActiveSupport::Logger do
  include MultibyteTestHelpers

  before do
    @message = "A debug message"
    @integer_message = 12345
    @output = StringIO.new
    @logger = described_class.new(@output)
  end

  it "is a Activesupport::Logger" do
    expect(described_class < Logger).to eq(true)
  end

  it "log_outputs_to" do
    assert described_class.logger_outputs_to?(@logger, @output), "Expected logger_outputs_to? @output to return true but was false"
    assert described_class.logger_outputs_to?(@logger, @output, STDOUT), "Expected logger_outputs_to? @output or STDOUT to return true but was false"

    assert_not described_class.logger_outputs_to?(@logger, STDOUT), "Expected logger_outputs_to? to STDOUT to return false, but was true"
    assert_not described_class.logger_outputs_to?(@logger, STDOUT, STDERR), "Expected logger_outputs_to? to STDOUT or STDERR to return false, but was true"
    assert_not described_class.logger_outputs_to?(@logger, "log/production.log")
  end

  it "log_outputs_to_with_a_broadcast_logger" do
    pending_for(engine: "truffleruby", reason: "Unclear why it is failing on truffleruby")
    logger = ActiveSupport::BroadcastLogger.new(described_class.new(STDOUT))

    assert(described_class.logger_outputs_to?(logger, STDOUT))
    # On truffle-ruby, unsure why it fails...
    #      Failure/Error: assert_not(described_class.logger_outputs_to?(logger, STDERR))
    #
    #      Test::Unit::AssertionFailedError:
    #        Expected true to be nil or false.
    #        <false> is not true.
    assert_not(described_class.logger_outputs_to?(logger, STDERR))

    logger.broadcast_to(described_class.new(STDERR))
    assert(described_class.logger_outputs_to?(logger, STDERR))
  end

  it "log_outputs_to_with_a_filename" do
    t = Tempfile.new ["development", "log"]
    logger = ActiveSupport::BroadcastLogger.new(described_class.new(t.path))

    assert described_class.logger_outputs_to?(logger, t)
    assert described_class.logger_outputs_to?(logger, t.path)
    assert described_class.logger_outputs_to?(logger, File.join(File.dirname(t.path), ".", File.basename(t.path)))
    assert_not described_class.logger_outputs_to?(logger, "log/production.log")
    assert_not described_class.logger_outputs_to?(logger, STDOUT)
  ensure
    logger.close
    t.close true
  end

  it "write_binary_data_to_existing_file" do
    t = Tempfile.new ["development", "log"]
    t.binmode
    t.write "hi mom!"
    t.close

    f = File.open(t.path, "w")
    f.binmode

    logger = described_class.new f
    logger.level = described_class::DEBUG

    str = +"\x80"
    str.force_encoding("ASCII-8BIT")

    assert_nothing_raised do
      logger.add described_class::DEBUG, str
    end
  ensure
    logger.close
    t.close true
  end

  it "write_binary_data_create_file" do
    fname = File.join Dir.tmpdir, "lol", "rofl.log"
    FileUtils.mkdir_p File.dirname(fname)
    f = File.open(fname, "w")
    f.binmode

    logger = described_class.new f
    logger.level = described_class::DEBUG

    str = +"\x80"
    str.force_encoding("ASCII-8BIT")

    assert_nothing_raised do
      logger.add described_class::DEBUG, str
    end
  ensure
    logger.close
    File.unlink fname
  end

  it "defaults_to_simple_formatter" do
    logger = described_class.new(@output)
    assert_instance_of described_class::SimpleFormatter, logger.formatter
  end

  it "formatter_can_be_set_via_keyword_arg" do
    custom_formatter = described_class::Formatter.new
    logger = described_class.new(@output, formatter: custom_formatter)
    assert_same custom_formatter, logger.formatter
  end

  it "should_log_debugging_message_when_debugging" do
    @logger.level = described_class::DEBUG
    @logger.add(described_class::DEBUG, @message)
    assert_includes @output.string, @message
  end

  it "should_not_log_debug_messages_when_log_level_is_info" do
    @logger.level = described_class::INFO
    @logger.add(described_class::DEBUG, @message)
    assert_not_includes @output.string, @message
  end

  it "should_add_message_passed_as_block_when_using_add" do
    @logger.level = described_class::INFO
    @logger.add(described_class::INFO) { @message }
    assert_includes @output.string, @message
  end

  it "should_add_message_passed_as_block_when_using_shortcut" do
    @logger.level = described_class::INFO
    @logger.info { @message }
    assert_includes @output.string, @message
  end

  it "should_convert_message_to_string" do
    @logger.level = described_class::INFO
    @logger.info @integer_message
    assert_includes @output.string, @integer_message.to_s
  end

  it "should_convert_message_to_string_when_passed_in_block" do
    @logger.level = described_class::INFO
    @logger.info { @integer_message }
    assert_includes @output.string, @integer_message.to_s
  end

  it "should_not_evaluate_block_if_message_wont_be_logged" do
    @logger.level = described_class::INFO
    evaluated = false
    @logger.add(described_class::DEBUG) { evaluated = true }
    assert evaluated == false
  end

  it "should_not_mutate_message" do
    message_copy = @message.dup
    @logger.info @message
    assert_equal message_copy, @message
  end

  it "should_know_if_its_loglevel_is_below_a_given_level" do
    described_class::Severity.constants.each do |level|
      next if level.to_s == "UNKNOWN"
      @logger.level = described_class::Severity.const_get(level) - 1
      assert @logger.public_send(:"#{level.downcase}?"), "didn't know if it was #{level.downcase}? or below"
    end
  end

  it "buffer_multibyte" do
    @logger.level = described_class::INFO
    @logger.info(MultibyteTestHelpers::UNICODE_STRING)
    @logger.info(MultibyteTestHelpers::BYTE_STRING)
    assert_includes @output.string, MultibyteTestHelpers::UNICODE_STRING
    byte_string = @output.string.dup
    byte_string.force_encoding("ASCII-8BIT")
    assert_includes byte_string, MultibyteTestHelpers::BYTE_STRING
  end

  it "silencing_everything_but_errors" do
    @logger.silence do
      @logger.debug "NOT THERE"
      @logger.error "THIS IS HERE"
    end

    assert_not_includes @output.string, "NOT THERE"
    assert_includes @output.string, "THIS IS HERE"
  end

  it "unsilencing" do
    @logger.level = described_class::INFO

    @logger.debug "NOT THERE"

    @logger.silence described_class::DEBUG do
      @logger.debug "THIS IS HERE"
    end

    assert_not_includes @output.string, "NOT THERE"
    assert_includes @output.string, "THIS IS HERE"
  end

  it "logger_silencing_works_for_broadcast" do
    another_output = StringIO.new
    another_logger = described_class.new(another_output)

    logger = ActiveSupport::BroadcastLogger.new(@logger, another_logger)

    logger.debug "CORRECT DEBUG"
    logger.silence do |logger|
      assert_kind_of ActiveSupport::BroadcastLogger, logger
      logger.debug "FAILURE"
      logger.error "CORRECT ERROR"
    end

    assert_includes @output.string, "CORRECT DEBUG"
    assert_includes @output.string, "CORRECT ERROR"
    assert_not_includes @output.string, "FAILURE"

    assert_includes another_output.string, "CORRECT DEBUG"
    assert_includes another_output.string, "CORRECT ERROR"
    assert_not another_output.string.include?("FAILURE")
  end

  it "broadcast_silencing_does_not_break_plain_ruby_logger" do
    another_output = StringIO.new
    another_logger = described_class.new(another_output)

    logger = ActiveSupport::BroadcastLogger.new(@logger, another_logger)

    logger.debug "CORRECT DEBUG"
    logger.silence do |logger|
      assert_kind_of ActiveSupport::BroadcastLogger, logger
      logger.debug "FAILURE"
      logger.error "CORRECT ERROR"
    end

    assert_includes @output.string, "CORRECT DEBUG"
    assert_includes @output.string, "CORRECT ERROR"
    assert_not_includes @output.string, "FAILURE"

    assert_includes another_output.string, "CORRECT DEBUG"
    assert_includes another_output.string, "CORRECT ERROR"
    # !!! WARNING !!!
    # This is a behavior change from vanilla Rails 8.0, which
    #   handled blocks poorly.  In these extraced, refactored, gems
    #   silencing the broadcast logger will prevent the log to all broadcasts.
    assert_not_includes another_output.string, "FAILURE"
  end

  it "logger_level_per_object_thread_safety" do
    logger1 = described_class.new(StringIO.new)
    logger2 = described_class.new(StringIO.new)

    level = described_class::DEBUG
    assert_equal level, logger1.level, "Expected level #{level_name(level)}, got #{level_name(logger1.level)}"
    assert_equal level, logger2.level, "Expected level #{level_name(level)}, got #{level_name(logger2.level)}"

    logger1.level = described_class::ERROR
    assert_equal level, logger2.level, "Expected level #{level_name(level)}, got #{level_name(logger2.level)}"
  end

  it "logger_level_main_thread_safety" do
    @logger.level = described_class::INFO
    assert_level(described_class::INFO)

    latch = Concurrent::CountDownLatch.new
    latch2 = Concurrent::CountDownLatch.new

    t = Thread.new do
      latch.wait
      assert_level(described_class::INFO)
      latch2.count_down
    end

    @logger.silence(described_class::ERROR) do
      assert_level(described_class::ERROR)
      latch.count_down
      latch2.wait
    end

    t.join
  end

  it "logger_level_local_thread_safety" do
    @logger.level = described_class::INFO
    assert_level(described_class::INFO)

    thread_1_latch = Concurrent::CountDownLatch.new
    thread_2_latch = Concurrent::CountDownLatch.new

    threads = (1..2).collect do |thread_number|
      Thread.new do
        # force thread 2 to wait until thread 1 is already in @logger.silence
        thread_2_latch.wait if thread_number == 2

        @logger.silence(described_class::ERROR) do
          assert_level(described_class::ERROR)
          @logger.silence(described_class::DEBUG) do
            # allow thread 2 to finish but hold thread 1
            if thread_number == 1
              thread_2_latch.count_down
              thread_1_latch.wait
            end
            assert_level(described_class::DEBUG)
          end
        end

        # allow thread 1 to finish
        assert_level(described_class::INFO)
        thread_1_latch.count_down if thread_number == 2
      end
    end

    threads.each(&:join)
    assert_level(described_class::INFO)
  end

  it "logger_level_main_fiber_safety" do
    previous_isolation_level = ActiveSupport::IsolatedExecutionState.isolation_level
    ActiveSupport::IsolatedExecutionState.isolation_level = :fiber

    @logger.level = described_class::INFO
    assert_level(described_class::INFO)

    fiber = Fiber.new do
      assert_level(described_class::INFO)
    end

    @logger.silence(described_class::ERROR) do
      assert_level(described_class::ERROR)
      fiber.resume
    end
  ensure
    ActiveSupport::IsolatedExecutionState.isolation_level = previous_isolation_level
  end

  it "logger_level_local_fiber_safety" do
    previous_isolation_level = ActiveSupport::IsolatedExecutionState.isolation_level
    ActiveSupport::IsolatedExecutionState.isolation_level = :fiber

    @logger.level = described_class::INFO
    assert_level(described_class::INFO)

    another_fiber = Fiber.new do
      @logger.silence(described_class::ERROR) do
        assert_level(described_class::ERROR)
        @logger.silence(described_class::DEBUG) do
          assert_level(described_class::DEBUG)
        end
      end

      assert_level(described_class::INFO)
    end

    Fiber.new do
      @logger.silence(described_class::ERROR) do
        assert_level(described_class::ERROR)
        @logger.silence(described_class::DEBUG) do
          another_fiber.resume
          assert_level(described_class::DEBUG)
        end
      end

      assert_level(described_class::INFO)
    end.resume

    assert_level(described_class::INFO)
  ensure
    ActiveSupport::IsolatedExecutionState.isolation_level = previous_isolation_level
  end

  it "logger_level_thread_safety" do
    previous_isolation_level = ActiveSupport::IsolatedExecutionState.isolation_level
    ActiveSupport::IsolatedExecutionState.isolation_level = :thread

    @logger.level = described_class::INFO
    assert_level(described_class::INFO)

    enumerator = Enumerator.new do |yielder|
      @logger.level = described_class::DEBUG
      yielder.yield @logger.level
    end
    assert_equal described_class::DEBUG, enumerator.next
    assert_level(described_class::DEBUG)
  ensure
    ActiveSupport::IsolatedExecutionState.isolation_level = previous_isolation_level
  end

  it "temporarily_logging_at_a_noisier_level" do
    @logger.level = described_class::INFO

    @logger.debug "NOT THERE"

    @logger.log_at described_class::DEBUG do
      @logger.debug "THIS IS HERE"
    end

    @logger.debug "NOT THERE"

    assert_not_includes @output.string, "NOT THERE"
    assert_includes @output.string, "THIS IS HERE"
  end

  it "temporarily_logging_at_a_quieter_level" do
    @logger.log_at described_class::ERROR do
      @logger.debug "NOT THERE"
      @logger.error "THIS IS HERE"
    end

    assert_not_includes @output.string, "NOT THERE"
    assert_includes @output.string, "THIS IS HERE"
  end

  it "temporarily_logging_at_a_symbolic_level" do
    @logger.log_at :error do
      @logger.debug "NOT THERE"
      @logger.error "THIS IS HERE"
    end

    assert_not_includes @output.string, "NOT THERE"
    assert_includes @output.string, "THIS IS HERE"
  end

  it "log_at_only_impact_receiver" do
    logger2 = described_class.new(StringIO.new)
    assert_equal described_class::DEBUG, logger2.level
    assert_equal described_class::DEBUG, @logger.level

    @logger.log_at :error do
      assert_equal described_class::DEBUG, logger2.level
      assert_equal described_class::ERROR, @logger.level
    end
  end

  private

  def level_name(level)
    described_class::Severity.constants.find do |severity|
      described_class.const_get(severity) == level
    end.to_s
  end

  def assert_level(level)
    assert_equal level, @logger.level, "Expected level #{level_name(level)}, got #{level_name(@logger.level)}"
  end
end
