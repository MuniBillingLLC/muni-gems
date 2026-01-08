require 'spec_helper'

RSpec.describe Muni::Login::Client::ToolBox do
  describe ".reject_blanks" do
    context "with a Hash" do
      it "removes keys with blank values" do
        input = { a: 1, b: nil, c: "", d: "value", e: [] }
        expect(described_class.reject_blanks(input)).to eq({ a: 1, d: "value" })
      end

      it "returns empty hash when all values are blank" do
        expect(described_class.reject_blanks({ a: nil, b: "" })).to eq({})
      end
    end

    context "with an Array" do
      it "removes blank values" do
        input = [1, nil, "", "value", []]
        expect(described_class.reject_blanks(input)).to eq([1, "value"])
      end

      it "returns empty array when all values are blank" do
        expect(described_class.reject_blanks([nil, "", []])).to eq([])
      end
    end

    context "with other types" do
      it "returns the input unchanged" do
        expect(described_class.reject_blanks("string")).to eq("string")
        expect(described_class.reject_blanks(123)).to eq(123)
        expect(described_class.reject_blanks(nil)).to be_nil
      end
    end
  end
end
