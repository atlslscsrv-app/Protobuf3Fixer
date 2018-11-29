# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'creating a PB from a hash' do
  let(:ts_subobject) do
    Testing::Examples::Timestamp::SubTs.new(
      ts: Google::Protobuf::Timestamp.new(seconds: 10)
    )
  end

  it 'converts timestamps' do
    expect(
      Protobuf3Fixer.build_from_hash(
        Testing::Examples::Timestamp::SubTs,
        ts: { seconds: 10 }
      )
    ).to eq(ts_subobject)
  end

  it 'raises an error on unknown fields' do
    expect do
      Protobuf3Fixer.build_from_hash(
        Testing::Examples::Timestamp::SubTs,
        ts: { seconds: 10 }, do_not_use_this_name: 'bar'
      )
    end.to raise_error Google::Protobuf::ParseError
  end
end
