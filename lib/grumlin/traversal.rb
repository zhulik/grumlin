# frozen_string_literal: true

module Grumlin
  class Traversal
    SUPPORTED_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze

    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze

    attr_reader :configuration_steps

    def initialize(pool = Grumlin.default_pool, configuration_steps: [])
      @pool = pool
      @configuration_steps = configuration_steps
    end

    def inspect
      "#<#{self.class}>"
    end

    def to_s
      inspect
    end

    CONFIGURATION_STEPS.each do |step|
      define_method step do |*args, **params|
        self.class.new(@pool, configuration_steps: @configuration_steps + [AnonymousStep.new(step, *args, **params)])
      end
    end

    SUPPORTED_STEPS.each do |step|
      define_method step do |*args, **params|
        Step.new(@pool, step, *args, configuration_steps: @configuration_steps, **params)
      end
    end
  end
end
