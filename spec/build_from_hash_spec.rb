# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'creating a PB from a hash' do
  let(:ts_subobject) do
    Testing::Examples::Timestamp::SubTs.new(
      ts: Google::Protobuf::Timestamp.new(seconds: 10)
    )
  end

  it 'raises an error on unknown fields' do
    expect do
      Protobuf3Fixer.build_from_hash(
        Testing::Examples::Timestamp::SubTs,
        ts: { seconds: 10 }
      )
    end.to raise_error Google::Protobuf::ParseError
  end
end
