# frozen_string_literal: true

module Grumlin
  module Expressions
    module T
      extend Tool

      SUPPORTED_STEPS = %i[id label].freeze

      define_steps(SUPPORTED_STEPS, "T")
    end
  end
end