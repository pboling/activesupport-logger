# frozen_string_literal: true

RSpec.describe ActiveSupport::Logger do
  before do
    @out = StringIO.new
    @logger = ActiveSupport::Logger.new(@out)
  end

  it "format_message" do
    @logger.error "error"
    assert_equal "error\n", @out.string
  end

  it "datetime_format" do
    @logger.formatter = Logger::Formatter.new
    @logger.formatter.datetime_format = "%Y-%m-%d"
    @logger.debug "debug"
    assert_equal "%Y-%m-%d", @logger.formatter.datetime_format
    assert_match(/D, \[\d\d\d\d-\d\d-\d\d[ ]?#\d+\] DEBUG -- : debug/, @out.string)
  end

  it "non-string_formatting" do
    an_object = [1, 2, 3, 4, 5]
    @logger.debug an_object
    assert_equal("#{an_object.inspect}\n", @out.string)
  end
end
