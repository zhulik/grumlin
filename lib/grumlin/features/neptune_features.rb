# frozen_string_literal: true

module Grumlin
  module Features
    class NeptuneFeatures
      def user_supplied_ids?
        true
      end

      def supports_transactions?
        true
      end
    end
  end
end
