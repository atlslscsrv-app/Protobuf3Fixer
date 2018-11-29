# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Protobuf3Fixer::GenerationHelpers do
  it 'creates a protobuf' do
    test_time = Time.now
    expect(
      Protobuf3Fixer::GenerationHelpers.create_timestamp(test_time)
    ).to have_attributes(
      seconds: test_time.to_i,
      nanos: test_time.nsec
    )
  end
end
