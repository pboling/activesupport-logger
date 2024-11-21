# frozen_string_literal: true

RSpec.describe ActiveSupport::LoggerSilence do
  class MyLogger < Logger
    include ActiveSupport::LoggerSilence
  end

  before do
    @io = StringIO.new
    @logger = MyLogger.new(@io)
  end

  it "#silence silences the log" do
    @logger.silence(Logger::ERROR) do
      @logger.info("Foo")
    end
    @io.rewind

    assert_empty @io.read
  end

  it "#debug? is true when setting the temporary level to Logger::DEBUG" do
    @logger.level = Logger::INFO

    @logger.silence(Logger::DEBUG) do
      assert_predicate @logger, :debug?
    end

    assert_predicate @logger, :info?
  end
end
