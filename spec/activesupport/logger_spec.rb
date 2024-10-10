# frozen_string_literal: true

RSpec.describe Activesupport::Logger do
  it "is not a ::Logger" do
    expect(described_class < Logger).to be_nil
  end
end

RSpec.describe ActiveSupport::Logger do
  it "is a ::Logger" do
    expect(described_class < Logger).to eq(true)
  end
end
