# frozen_string_literal: true

module Grumlin
  module Expressions
    module Order
      extend Tool

      SUPPORTED_STEPS = %i[asc desc].freeze

      define_steps(SUPPORTED_STEPS, "Order")
    end
  end
end