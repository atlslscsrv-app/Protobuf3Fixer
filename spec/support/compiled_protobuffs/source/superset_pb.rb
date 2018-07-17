# frozen_string_literal: true

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: source/superset.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'testing.examples.extra_fields.SubField1' do
    optional :fielda, :string, 1
  end
  add_message 'testing.examples.extra_fields.SuperSubField1' do
    optional :fielda, :string, 1
    optional :fieldb, :string, 2
  end
  add_message 'testing.examples.extra_fields.Subset' do
    optional :field1, :string, 1
    repeated :arrField, :message, 2, 'testing.examples.extra_fields.SubField1'
    map :mapField, :string, :message, 3, 'testing.examples.extra_fields.SubField1'
    optional :subMsg, :message, 4, 'testing.examples.extra_fields.SubField1'
    repeated :foo, :string, 5
    map :bar, :string, :string, 6
  end
  add_message 'testing.examples.extra_fields.Superset' do
    optional :field1, :string, 1
    repeated :arrField, :message, 2, 'testing.examples.extra_fields.SuperSubField1'
    map :mapField, :string, :message, 3, 'testing.examples.extra_fields.SuperSubField1'
    optional :subMsg, :message, 4, 'testing.examples.extra_fields.SuperSubField1'
    repeated :foo, :string, 5
    map :bar, :string, :string, 6
    repeated :foo_extra, :string, 7
    map :bar_extra, :string, :string, 8
    optional :field2, :string, 9
  end
end

module Testing
  module Examples
    module ExtraFields
      SubField1 = Google::Protobuf::DescriptorPool.generated_pool.lookup('testing.examples.extra_fields.SubField1').msgclass
      SuperSubField1 = Google::Protobuf::DescriptorPool.generated_pool.lookup('testing.examples.extra_fields.SuperSubField1').msgclass
      Subset = Google::Protobuf::DescriptorPool.generated_pool.lookup('testing.examples.extra_fields.Subset').msgclass
      Superset = Google::Protobuf::DescriptorPool.generated_pool.lookup('testing.examples.extra_fields.Superset').msgclass
    end
  end
end
