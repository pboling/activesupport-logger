# frozen_string_literal: true

require "rspec"

RSpec.describe ActiveSupport::IsolatedExecutionState do
  before do
    described_class.clear
    @original_isolation_level = described_class.isolation_level
  end

  after do
    described_class.clear
    described_class.isolation_level = @original_isolation_level
  end

  it "#[] when isolation level is :fiber" do
    described_class.isolation_level = :fiber

    described_class[:test] = 42
    assert_equal 42, described_class[:test]
    enumerator = Enumerator.new do |yielder|
      yielder.yield described_class[:test]
    end
    assert_nil enumerator.next

    assert_nil Thread.new { described_class[:test] }.value
  end

  it "#[] when isolation level is :thread" do
    described_class.isolation_level = :thread

    described_class[:test] = 42
    assert_equal 42, described_class[:test]
    enumerator = Enumerator.new do |yielder|
      yielder.yield described_class[:test]
    end
    assert_equal 42, enumerator.next

    assert_nil Thread.new { described_class[:test] }.value
  end

  it "changing the isolation level clear the old store" do
    original = described_class.isolation_level
    other = (described_class.isolation_level == :fiber) ? :thread : :fiber

    described_class[:test] = 42
    described_class.isolation_level = original
    assert_equal 42, described_class[:test]

    described_class.isolation_level = other
    assert_nil described_class[:test]

    described_class.isolation_level = original
    assert_nil described_class[:test]
  end
end
