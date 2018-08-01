# frozen_string_literal: true

require 'protobuf3_fixer/version'
require 'protobuf3_fixer/reflector'
require 'json'
require 'date'

module Protobuf3Fixer
  class << self
    def reflect_on(klass)
      @reflectors ||= Hash.new do |h, k|
        h[k] = Protobuf3Fixer::Reflector.new(k)
      end

      @reflectors[klass]
    end

    def encode_json(instance)
      generated_json_hash = JSON.parse(instance.class.encode_json(instance))

      clean_encoded_json_for_klass(
        generated_json_hash,
        instance.class
      ).to_json
    end

    def clean_encoded_json_for_klass(data, klass)
      reflector = reflect_on(klass)

      data.each_with_object({}) do |(k, v), hsh|
        klass = reflector.subklass_for(k)
        hsh[k] = if klass == Google::Protobuf::Timestamp
                   Time.at(v['seconds'], (v['nanos'] || 0) / 10**6).utc.to_datetime.rfc3339
                 else
                   puts "In else for #{k}"
                   v
                 end
      end
    end

    def decode_json(klass, json)
      parsed_json = JSON.parse(json)
      cleaned_obj = clean_json_data_for_klass(klass, parsed_json)
      klass.decode_json(cleaned_obj.to_json)
    end

    def rework_for_well_known_types(klass, data)
      if klass == Google::Protobuf::Timestamp
        time = DateTime.rfc3339(data).to_time
        { 'seconds' => time.to_i, 'nanos' => time.nsec }
      else
        data
      end
    end

    def clean_json_data_for_klass(klass, data)
      data = rework_for_well_known_types(klass, data)
      return data unless data.is_a?(Hash)
      reflector = reflect_on(klass)

      # Remove unknown fields
      known_fields = prune_and_organize_fields(reflector, data)

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

    def prune_and_organize_fields(reflector, data)
      data.each_with_object({}) do |(k, v), fields|
        json_field_name = k
        local_field_name = if reflector.field_names.include?(rubyized_field_name(k))
                             rubyized_field_name(k)
                           elsif reflector.field_names.include?(k)
                             k
                           end

        next unless local_field_name

        fields[[json_field_name, local_field_name]] = v
      end
    end

    def rubyized_field_name(field_name)
      field_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').tap(&:downcase!)
    end
  end
end
