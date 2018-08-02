require 'google/protobuf/well_known_types'

module Protobuf3Fixer
  class Encoder
    attr_accessor :klass, :data, :reflector
    def initialize(klass, data)
      self.klass = klass
      self.data = data
      self.reflector = Protobuf3Fixer.reflect_on(klass)
    end

    def reencoded_hash
      clean_encoded_json_for_klass
    end

    private

    def clean_encoded_json_for_klass
      case required_typefix
      when :timestamp
        Time.at(data['seconds'], (data['nanos'] || 0) / 10**6).utc.to_datetime.rfc3339
      else
        deep_parse_object
      end
    end

    def deep_parse_object
      data.each_with_object({}) do |(k, v), hsh|
        rb_field_name = rubyized_field_name(k)
        klass = reflector.subklass_for(k) || reflector.subklass_for(rb_field_name)
        type = reflector.field_type(k) || reflector.field_type(rb_field_name)
        hsh[k] = parse_value_for_type(klass, type, v)
      end
    end

    def parse_value_for_type(klass, type, value)
      case type
      when Protobuf3Fixer::Reflector::TYPE_ARRAY
        value.collect do |array_item|
          self.class.new(klass, array_item).reencoded_hash
        end
      when Protobuf3Fixer::Reflector::TYPE_MAP
        value.each_with_object({}) do |(map_key, sub_object), new_hash|
          new_hash[map_key] = self.class.new(klass, sub_object).reencoded_hash
        end
      when Protobuf3Fixer::Reflector::TYPE_SUB_OBJECT
        self.class.new(klass, value).reencoded_hash
      else
        value
      end
    end

    def required_typefix
      if klass == Google::Protobuf::Timestamp
        :timestamp
      end
    end

    def rubyized_field_name(field_name)
      field_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').tap(&:downcase!)
    end
  end
end
