# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Protobuf3Fixer::GenerationHelpers do
  it 'creates a timestamp proto' do
    test_time = Time.now
    expect(
      Protobuf3Fixer::GenerationHelpers.create_timestamp(test_time)
    ).to have_attributes(
      seconds: test_time.to_i,
      nanos: test_time.nsec
    )
  end

  it 'creates a date proto from a date' do
    test_date = Date.today
    expect(
      Protobuf3Fixer::GenerationHelpers.create_date(test_date)
    ).to have_attributes(
      year: test_date.year,
      month: test_date.month,
      day: test_date.day
    )
  end

  it 'creates a date proto from a string' do
    test_date = '2019-10-12'
    expect(
      Protobuf3Fixer::GenerationHelpers.create_date(test_date)
    ).to have_attributes(
      year: 2019,
      month: 10,
      day: 12
    )
  end
end
