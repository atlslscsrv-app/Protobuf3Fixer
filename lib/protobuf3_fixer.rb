# frozen_string_literal: true

require 'json'
require 'date'
require 'google/protobuf/well_known_types'

require 'protobuf3_fixer/version'
require 'protobuf3_fixer/reflector'
require 'protobuf3_fixer/encoder'

module Protobuf3Fixer
  class << self
    def reflect_on(klass)
      @reflectors ||= Hash.new do |h, k|
        h[k] = Protobuf3Fixer::Reflector.new(k)
      end

      @reflectors[klass]
    end

    def encode_json(instance)
      fixed_transmission_hash(instance).to_json
    end

    def decode_json(klass, json)
      build_from_hash(klass, JSON.parse(json), clean: true)
    end

    def fixed_transmission_hash(instance)
      generated_json_hash = JSON.parse(instance.class.encode_json(instance))

      Protobuf3Fixer::Encoder.new(
        instance.class,
        generated_json_hash
      ).reencoded_hash
    end

    def build_from_hash(klass, hash_data, clean: false)
      cleaned_obj = clean_json_data_for_klass(klass, deep_stringify_keys(hash_data), clean: clean)
      klass.decode_json(cleaned_obj.to_json)
    end

    private

    def deep_stringify_keys(hash_data)
      hash_data.each_with_object({}) do |(k, v), hsh|
        hsh[k.to_s] = v.is_a?(Hash) ? deep_stringify_keys(v) : v
      end
    end

    def rework_for_well_known_types(klass, data)
      if klass == Google::Protobuf::Timestamp && data.is_a?(String)
        time = DateTime.rfc3339(data).to_time
        { 'seconds' => time.to_i, 'nanos' => time.nsec }
      else
        data
      end
    end

    def clean_json_data_for_klass(klass, data, clean: true)
      data = rework_for_well_known_types(klass, data)
      return data unless data.is_a?(Hash)
      reflector = reflect_on(klass)

      # Remove unknown fields
      known_fields = prune_and_organize_fields(reflector, data, clean: clean)

      final_data = {}

      known_fields.each do |(json_field, ruby_field), original_value|
        subklass = reflector.subklass_for(ruby_field)

        if subklass
          data = parse_data_for_subklass(
            subklass,
            reflector.field_type(ruby_field),
            original_value
          )
          final_data[json_field] = data if data
        else
          final_data[json_field] = original_value
        end
      end

      final_data
    end

    def parse_data_for_subklass(subklass, type, data)
      case type
      when Protobuf3Fixer::Reflector::TYPE_ARRAY
        data.collect do |sub_object|
          clean_json_data_for_klass(subklass, sub_object)
        end
      when Protobuf3Fixer::Reflector::TYPE_MAP
        data.each_with_object({}) do |(map_key, sub_object), new_hash|
          new_hash[map_key] = clean_json_data_for_klass(subklass, sub_object)
          new_hash
        end
      when Protobuf3Fixer::Reflector::TYPE_SUB_OBJECT
        clean_json_data_for_klass(subklass, data) if data
      end
    end

    def prune_and_organize_fields(reflector, data, clean: true)
      data.each_with_object({}) do |(k, v), fields|
        json_field_name = k
        local_field_name = if reflector.field_names.include?(rubyized_field_name(k))
                             rubyized_field_name(k)
                           elsif reflector.field_names.include?(k)
                             k
                           end

        next if clean && !local_field_name

        local_field_name ||= json_field_name

        fields[[json_field_name, local_field_name]] = v
      end
    end

    def rubyized_field_name(field_name)
      field_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').tap(&:downcase!)
    end
  end
end
