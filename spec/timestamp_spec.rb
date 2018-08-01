# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'decoding a superset of fields via json' do
  let(:ts_subobject) do
    Testing::Examples::Timestamp::SubTs.new(
      ts: Google::Protobuf::Timestamp.new(seconds: 10),
      ts_one: Google::Protobuf::Timestamp.new(seconds: 10),
      tsTwo: Google::Protobuf::Timestamp.new(seconds: 10)
    )
  end

  it 'generates incorrect behavior using the provided encoder' do
    expect(
      ts_subobject.to_json
    ).to eq('{"ts":{"seconds":10},"tsOne":{"seconds":10},"tsTwo":{"seconds":10}}')
  end

  it 'generates timestamps encoded as RFC3339' do
    expect(
      Protobuf3Fixer.encode_json(ts_subobject)
    ).to eq(%({"ts":"#{Time.at(10).utc.to_datetime.rfc3339}","tsOne":"#{Time.at(10).utc.to_datetime.rfc3339}","tsTwo":"#{Time.at(10).utc.to_datetime.rfc3339}"}))
  end

  it 'decodes the json it generates' do
    expect(
      Protobuf3Fixer.decode_json(
        Testing::Examples::Timestamp::SubTs,
        Protobuf3Fixer.encode_json(ts_subobject)
      )
    ).to eq ts_subobject
  end
end
