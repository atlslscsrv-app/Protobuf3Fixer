# frozen_string_literal: true

module Protobuf3Fixer
  class Reflector
    TYPE_PLAIN      = :plain
    TYPE_ARRAY      = :array
    TYPE_MAP        = :map
    TYPE_SUB_OBJECT = :subobject

    attr_accessor :klass, :instance, :field_info, :field_names
    def initialize(klass)
      self.klass = klass
      reflect!
    end

    def reflect!
      self.field_info = {}
      self.field_names = Set.new

      self.instance = klass.new
      klass.descriptor.each(&method(:reflect_on_field))
    end

    def field_type(field_name)
      field_info[field_name][:type] if field_info[field_name]
    end

    def subklass_for(field_name)
      field_info[field_name] && field_info[field_name][:klass]
    end

    def reflect_on_field(desc)
      type = if desc.type == :message
               determine_complex_type(instance.public_send(desc.name))
             else
               TYPE_PLAIN
             end

      field_names << desc.name
      field_info[desc.name] = {
        klass: divine_type(type, desc),
        type: type,
      }
    end

    def divine_type(type, descriptor)
      case type
      when TYPE_MAP
        descriptor.subtype.to_a[1].subtype&.msgclass
      when TYPE_ARRAY, TYPE_SUB_OBJECT
        descriptor.subtype&.msgclass
      end
    end

    def determine_complex_type(result)
      case result
      when Google::Protobuf::RepeatedField
        TYPE_ARRAY
      when Google::Protobuf::Map
        TYPE_MAP
      else
        TYPE_SUB_OBJECT
      end
    end
  end
end
