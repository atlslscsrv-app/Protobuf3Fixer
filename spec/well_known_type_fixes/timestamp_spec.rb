# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'decoding a superset of fields via json' do
  let(:ts_subobject) do
    Testing::Examples::Timestamp::SubTs.new(
      ts: Google::Protobuf::Timestamp.new(seconds: 10),
      ts_one: Google::Protobuf::Timestamp.new(seconds: 10),
      tsTwo: Google::Protobuf::Timestamp.new(seconds: 10),
      foo: [Google::Protobuf::Timestamp.new(seconds: 10)],
      bar: { 'a' => Google::Protobuf::Timestamp.new(seconds: 10) }
    )
  end

  let(:ts_parentobj) do
    Testing::Examples::Timestamp::ParentTs.new(
      abc: ts_subobject
    )
  end

  let(:ts_subobject_json) do
  end

  it 'works on a strait up timestamp' do
    expect(
      Protobuf3Fixer.encode_json(
        Google::Protobuf::Timestamp.new(seconds: 10)
      )
    ).to eq('1970-01-01T00:00:10Z'.to_json)
  end

  it 'generates timestamps encoded as RFC3339' do
    expect(
      Protobuf3Fixer.encode_json(ts_subobject)
        .yield_self(&JSON.method(:parse))
    ).to eq(
      'ts'    => '1970-01-01T00:00:10Z',
      'tsOne' => '1970-01-01T00:00:10Z',
      'tsTwo' => '1970-01-01T00:00:10Z',
      'foo'   => ['1970-01-01T00:00:10Z'],
      'bar'   => { 'a' => '1970-01-01T00:00:10Z' }
    )
  end

  it 'decodes the json it generates' do
    expect(
      Protobuf3Fixer.decode_json(
        Testing::Examples::Timestamp::SubTs,
        Protobuf3Fixer.encode_json(ts_subobject)
      )
    ).to eq ts_subobject
  end

  context 'subobjects' do
    it 'handles subobjects' do
      expect(
        Protobuf3Fixer.encode_json(ts_parentobj).yield_self(&JSON.method(:parse))
      ).to eq(
        'abc' => {
          'ts'    => '1970-01-01T00:00:10Z',
          'tsOne' => '1970-01-01T00:00:10Z',
          'tsTwo' => '1970-01-01T00:00:10Z',
          'foo'   => ['1970-01-01T00:00:10Z'],
          'bar'   => { 'a' => '1970-01-01T00:00:10Z' },
        }
      )
    end

    it 'handles encode -> decode' do
      expect(
        Protobuf3Fixer.decode_json(
          Testing::Examples::Timestamp::ParentTs,
          Protobuf3Fixer.encode_json(ts_parentobj)
        )
      ).to eq ts_parentobj
    end
  end
end
