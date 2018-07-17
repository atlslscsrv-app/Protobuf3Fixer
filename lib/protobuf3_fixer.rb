# frozen_string_literal: true

require 'protobuf3_fixer/version'
require 'protobuf3_fixer/reflector'
require 'json'

module Protobuf3Fixer
  class << self
    def reflect_on(klass)
      @reflectors ||= Hash.new do |h, k|
        h[k] = Protobuf3Fixer::Reflector.new(k)
      end

      @reflectors[klass]
    end

    def decode_json(klass, json)
      parsed_json = JSON.parse(json)
      cleaned_obj = clean_data_for_klass(klass, parsed_json)
      klass.decode_json(cleaned_obj.to_json)
    end

    def clean_data_for_klass(klass, data)
      return unless data
      reflector = reflect_on(klass)

      # Remove unknown fields
      known_fields = data.select do |k, _|
        reflector.field_names.include?(k)
      end

      known_fields.each do |k, v|
        subklass = reflector.subklass_for(k)
        next unless subklass
        case reflector.field_type(k)
        when Protobuf3Fixer::Reflector::TYPE_ARRAY
          known_fields[k] = v.collect do |sub_object|
            clean_data_for_klass(subklass, sub_object)
          end
        when Protobuf3Fixer::Reflector::TYPE_MAP
          known_fields[k] = v.each_with_object({}) do |(map_key, sub_object), new_hash|
            new_hash[map_key] = clean_data_for_klass(subklass, sub_object)
            new_hash
          end
        when Protobuf3Fixer::Reflector::TYPE_SUB_OBJECT
          known_fields[k] = clean_data_for_klass(subklass, v) if v
        end
      end
    end
  end
end
