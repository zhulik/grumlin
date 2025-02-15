# frozen_string_literal: true

RSpec.describe Grumlin::Vertex do
  let(:attrs) { { label: "vertex", id: 123 } }

  describe ".new" do
    it "properly assigns all instance variables" do
      vertex = described_class.new(**attrs)
      expect(vertex).to have_attributes(attrs)
    end
  end

  describe "#inspect" do
    it "returns string representation of the vertex" do
      vertex = described_class.new(**attrs)
      expect(vertex.inspect).to eq("v[123]")
    end
  end

  describe "#==" do
    subject { vertex == other_vertex }

    let(:vertex) { described_class.new(**attrs) }

    context "when the other object is equal" do
      let(:other_vertex) { described_class.new(**attrs) }

      include_examples "returns true"
    end

    context "when the other object is not equal" do
      let(:other_vertex) do
        described_class.new(label: "vertex", id: 234)
      end

      include_examples "returns false"
    end
  end
end
