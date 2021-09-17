# frozen_string_literal: true

module Grumlin
  module Tools
    module U
      # TODO: add other start steps
      SUPPORTED_STEPS = %i[V addV count fold has id inV label out outV project repeat timeLimit unfold valueMap
                           values].freeze

      class << self
        SUPPORTED_STEPS.each do |step|
          define_method step do |*args|
            AnonymousStep.new(step, *args)
          end
        end
      end
    end
  end
end