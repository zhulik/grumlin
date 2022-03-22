# frozen_string_literal: true

module Grumlin
  module Repository
    RETURN_MODES = {
      list: :toList,
      none: :iterate,
      single: :next,
      traversal: :nil
    }.freeze

    module InstanceMethods
      def __
        TraversalStart.new(self.class.shortcuts)
      end

      def g
        TraversalStart.new(self.class.shortcuts)
      end
    end

    def self.extended(base)
      base.extend(Grumlin::Shortcuts)
      base.include(Grumlin::Expressions)
      base.include(InstanceMethods)

      base.shortcuts_from(Grumlin::Shortcuts::Properties)
    end

    def query(name, return_mode: :list, postprocess_with: nil, &query_block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      return_mode = validate_return_mode!(return_mode)

      define_method name do |*args, query_params: {}, **params, &block|
        t = instance_exec(*args, **params, &query_block)
        return t if self.class.empty_result?(t)

        unless t.is_a?(Grumlin::Action)
          raise WrongQueryResult,
                "queries must return #{Grumlin::Action}, nil or an empty collection. Given: #{t.class}"
        end

        return block.call(t) unless block.nil?

        return t.profile.next if query_params[:profile] == true

        return_mode = self.class.validate_return_mode!(query_params[:return_mode] || return_mode)

        return t if return_mode == :traversal

        t.public_send(RETURN_MODES[return_mode]).tap do |result|
          return send(postprocess_with, result) unless postprocess_with.nil?
        end
      end
    end

    def validate_return_mode!(return_mode)
      return return_mode if RETURN_MODES.key?(return_mode)

      raise ArgumentError, "unsupported return mode #{return_mode}. Supported modes: #{RETURN_MODES.keys}"
    end

    def empty_result?(result)
      result.nil? || (result.respond_to?(:empty?) && result.empty?)
    end
  end
end
