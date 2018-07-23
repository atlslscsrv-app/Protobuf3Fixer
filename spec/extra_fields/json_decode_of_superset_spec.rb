# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'decoding a superset of fields via json' do
  let(:subset_subobject) do
    Testing::Examples::ExtraFields::SubField1.new(fielda: 'abc')
  end

  let(:superset_subobject) do
    Testing::Examples::ExtraFields::SuperSubField1.new(
      fielda: 'abc',
      fieldb: 'def'
    )
  end

  let(:superset_json) do
    Testing::Examples::ExtraFields::Superset.encode_json(
      Testing::Examples::ExtraFields::Superset.new(
        field1: 'abc',
        field2: 'def',
        arr_field: [superset_subobject],
        mapField: { 'abc' => superset_subobject },
        subMsg: superset_subobject,
        foo: %w[1 2 3],
        bar: { 'a' => 'b' },
        foo_extra: %w[a b],
        bar_extra: { 'd' => 'e' }
      )
    )
  end

  it 'errors using the provided decoders' do
    expect do
      Testing::Examples::ExtraFields::Subset.decode_json(superset_json)
    end.to raise_error Google::Protobuf::ParseError
  end

  it 'properly parses a superset of top level fields' do
    expect(
      Protobuf3Fixer.decode_json(
        Testing::Examples::ExtraFields::Subset,
        superset_json
      )
    ).to eq Testing::Examples::ExtraFields::Subset.new(
      field1: 'abc',
      arr_field: [subset_subobject],
      mapField: { 'abc' => subset_subobject },
      subMsg: subset_subobject,
      foo: %w[1 2 3],
      bar: { 'a' => 'b' },
    )
  end
end
