# frozen_string_literal: true

module Grumlin
  module Test
    module RSpec
      module GremlinContext
      end

      ::RSpec.shared_context GremlinContext do
        include GremlinContext

        let!(:client) { Grumlin::Client.new(Grumlin.config.url) }
        let(:g) { Grumlin::Traversal.new(client) }

        after do
          expect(client.requests).to be_empty
          client.disconnect
        end
      end
    end
  end
end
