# frozen_string_literal: true

module Protobuf3Fixer
  module GenerationHelpers
    TIMESTAMP = Google::Protobuf::DescriptorPool.generated_pool.lookup('google.protobuf.Timestamp').msgclass

    def self.create_timestamp(stmp)
      TIMESTAMP.new.tap { |t| t.from_time(stmp) }
    end
  end
end
