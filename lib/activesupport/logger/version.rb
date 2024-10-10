# frozen_string_literal: true

# NOTE: This is a different namespace than the Rails one.
# Lowercase "s" here, uppercase in Rails.
#  This is to avoid a superclass mismatch for Logger.
module Activesupport
  module Logger
    module Version
      VERSION = "1.0.1"
    end
  end
end
