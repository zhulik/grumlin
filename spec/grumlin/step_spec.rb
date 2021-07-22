# frozen_string_literal: true

RSpec.describe Grumlin::Step, gremlin_server: true do
  describe "chaining" do
    context "when using aliases" do
      it "builds a chain" do # rubocop:disable RSpec/MultipleExpectations
        g.addV.as("first")
         .addV.as("second")
         .addV.as("third")
         .addE("follows").from("first").to("second")
         .addE("follows").from("second").to("third")
         .addE("follows").from("third").to("first").iterate

        expect(g.V().count.toList).to eq([3])
        expect(g.E().count.toList).to eq([3])
      end
    end

    context "when using anonymous queries" do
      it "builds a chain" do # rubocop:disable RSpec/MultipleExpectations
        g.addV.property(Grumlin::T.id, 1)
         .addV.property(Grumlin::T.id, 2)
         .addV.property(Grumlin::T.id, 3).iterate

        t = g.addE("follows").from(Grumlin::U.V(1)).to(Grumlin::U.V(2))
             .addE("follows").from(Grumlin::U.V(2)).to(Grumlin::U.V(3))
             .addE("follows").from(Grumlin::U.V(3)).to(Grumlin::U.V(1))
        t.iterate

        expect(g.V().count.toList).to eq([3])
        expect(g.E().count.toList).to eq([3])
      end
    end

    context "when using elementMap" do
      before do
        g.addV(:test_label).property(Grumlin::T.id, 1).property("foo1", "bar").property("foo3", 3)
         .addV(:test_label).property(Grumlin::T.id, 2).property("foo2", "bar")
         .addV(:test_label).property(Grumlin::T.id, 3).property("foo3", 3).iterate
      end

      it "returns a map" do
        g.V().elementMap.toList
      end
    end
  end
end
