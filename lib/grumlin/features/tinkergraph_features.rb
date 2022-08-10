# frozen_string_literal: true

module Grumlin
  module Features
    class TinkergraphFeatures < FeatureList
      def user_supplied_ids?
        true
      end

      def supports_transactions?
        false
      end
    end
  end
end