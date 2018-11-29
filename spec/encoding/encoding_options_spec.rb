# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'options passed to encode_json' do
  describe 'persisting defaults' do
    let(:pb_object_with_defaults) do
      Testing::Examples::ExtraFields::SubField1.new
    end

    it 'excludes defaults' do
      expect(
        Protobuf3Fixer.encode_json(pb_object_with_defaults)
      ).to eq('{}')
    end

    it 'allows the inclusion of defaults' do
      expect(
        Protobuf3Fixer.encode_json(pb_object_with_defaults, emit_defaults: true)
      ).to eq('{"fielda":""}')
    end
  end
end
