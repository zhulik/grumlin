# frozen_string_literal: true

RSpec.describe Grumlin::StepsSerializers::HumanReadableBytecode, :gremlin do
  let(:serializer) { described_class.new(steps) }

  # TODO: add cases with predicates

  let(:shortcuts) do
    {
      hasColor: Grumlin::Shortcut.new(:hasColor) { |color| has(:color, color) },
      hasShape: Grumlin::Shortcut.new(:hasShape) { |shape| has(:shape, shape) },
      hasShapeAndColor: Grumlin::Shortcut.new(:hasShapeAndColor) { |shape, color| hasShape(shape).hasColor(color) },
      addWeights: Grumlin::Shortcut.new(:addWeights) { withSideEffect(:weights, a: 1, b: 2) },
      preconfigure: Grumlin::Shortcut.new(:preconfigure) { addWeights }
    }
  end

  describe "#serialize" do
    subject { serializer.serialize }

    context "when there are no anonymous traversals" do
      let(:steps) { g.V.has(:color, :white).has(:shape, :rectangle).steps }

      it "returns a human readable bytecode representation of steps" do
        expect(subject).to eq([[], [[:V], [:has, :color, :white], [:has, :shape, :rectangle]]])
      end
    end

    context "when there are anonymous traversals" do
      let(:steps) { g.V.where(__.has(:color, :white)).has(:shape, :rectangle).steps }

      it "returns a human readable bytecode representation of steps" do
        expect(subject).to eq([[], [[:V], [:where, [[:has, :color, :white]]], [:has, :shape, :rectangle]]])
      end
    end

    context "when Expressions::T is used" do
      let(:steps) { g.V.has(Grumlin::Expressions::T.id, "id").steps }

      it "returns a human readable bytecode representation of steps" do
        expect(subject).to eq([[], [[:V], [:has, "<T.id>", "id"]]])
      end
    end

    context "when Expressions::WithOptions is used" do
      let(:steps) { g.V.with(Grumlin::Expressions::WithOptions.tokens).steps }

      it "returns a human readable bytecode representation of steps" do
        expect(subject).to eq([[], [[:V], [:with, "~tinkerpop.valueMap.tokens"]]])
      end
    end

    context "when configuration steps are used" do
      let(:steps) { g.withSideEffect(:a, 1).V.has(:property, :value).steps }

      it "returns a human readable bytecode representation of steps" do
        expect(subject).to eq([[[:withSideEffect, :a, 1]], [[:V], [:has, :property, :value]]])
      end
    end

    context "when predicates are used" do
      context "when using P.eq" do
        let(:steps) { g.V.where(P.eq("test")).steps }

        it "returns a human readable bytecode representation of steps" do
          expect(subject).to eq([[], [[:V], [:where, "eq(test)"]]])
        end
      end

      context "when using P.within" do
        let(:steps) { g.V.where(P.within(["test", "another_test"])).steps }

        it "returns a human readable bytecode representation of steps" do
          expect(subject).to eq([[], [[:V], [:where, 'within(["test", "another_test"])']]])
        end
      end
    end
  end
end
