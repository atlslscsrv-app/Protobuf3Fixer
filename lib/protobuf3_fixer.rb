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
      return data unless data.is_a?(Hash)
      reflector = reflect_on(klass)

      # Remove unknown fields
      known_fields = prune_and_organize_fields(reflector, data)

      final_data = {}

      known_fields.each do |(json_field, ruby_field), v|
        subklass = reflector.subklass_for(ruby_field)

        if subklass
          case reflector.field_type(ruby_field)
          when Protobuf3Fixer::Reflector::TYPE_ARRAY
            final_data[json_field] = v.collect do |sub_object|
              clean_data_for_klass(subklass, sub_object)
            end
          when Protobuf3Fixer::Reflector::TYPE_MAP
            final_data[json_field] = v.each_with_object({}) do |(map_key, sub_object), new_hash|
              new_hash[map_key] = clean_data_for_klass(subklass, sub_object)
              new_hash
            end
          when Protobuf3Fixer::Reflector::TYPE_SUB_OBJECT
            final_data[json_field] = clean_data_for_klass(subklass, v) if v
          end
        else
          final_data[json_field] = v
        end
      end

      final_data
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
