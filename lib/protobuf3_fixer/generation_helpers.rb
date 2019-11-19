# frozen_string_literal: true

require 'date'

module Protobuf3Fixer
  module GenerationHelpers
    TIMESTAMP = Google::Protobuf::DescriptorPool.generated_pool.lookup('google.protobuf.Timestamp').msgclass
    DATE = Google::Protobuf::DescriptorPool.generated_pool.lookup('google.type.Date').msgclass

    def self.create_timestamp(stmp)
      TIMESTAMP.new.tap { |t| t.from_time(stmp) }
    end

    def self.create_date(date)
      date = Date.parse(date) if date.is_a? String
      DATE.new.tap do |d|
        d.year = date.year
        d.month = date.month
        d.day = date.day
      end
    end
  end
end
