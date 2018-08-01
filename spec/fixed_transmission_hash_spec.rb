# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'creating a hash prior to jsonification' do
  let(:ts_subobject) do
    Testing::Examples::Timestamp::SubTs.new(
      ts: Google::Protobuf::Timestamp.new(seconds: 10)
    )
  end

  it 'converts timestamps' do
    expect(
      Protobuf3Fixer.fixed_transmission_hash(ts_subobject)
    ).to eq('ts' => Time.at(10).utc.to_datetime.rfc3339)
  end
end
