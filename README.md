# Protobuf3Fixer

This gem is a thin wrapper to fix some of the non-conformance of the ruby
protobuff plugin


## Encoding
Protobuf3Fixer changes the encoding behavior to properly encode some well known types.

## Encoding Options
The default protobuf encoding contains a set of encoding options, which are not
quite obvious. You may specify any of these arguments in the PB3Fixer library via
an options hash.

### Emit Defaults
Given the following proto:

```
message TestMsg {
  string field = 1;
}
```

```ruby
Protobuf3Fixer.encode_json(TestMsg.new)
# => {}

Protobuf3Fixer.encode_json(TestMsg.new, emit_defaults: true)
# => {"field":""}
```

### Timestamps (Well Known Type)
Given the following protofile:
```ruby
syntax = "proto3";

import "google/protobuf/timestamp.proto";

package testing.examples.timestamp;

message SubTs {
  google.protobuf.Timestamp ts = 2;
}
```

The default behavior of the Proto library is:
```ruby
Testing::Examples::Timestamp::SubTs.new(
  ts: Google::Protobuf::Timestamp.new(seconds: 10)
).to_json
# => {"ts":{"seconds":10}}
```

This is incorrect as the specification calls for Timestamps to be encoded as an
RFC3339 string

Using Proto3Fixer, you get this behavior:

```ruby
Protobuf3Fixer.encode_json(Testing::Examples::Timestamp::SubTs.new(
  ts: Google::Protobuf::Timestamp.new(seconds: 10)
))
# => {"ts":"1970-01-01T00:00:10+00:00"}
```



## Decoding
```ruby
Protobuf3Fixer.decode_json(ProtobufMessageClass, json_string)
```

Ignores unknown fields, given the following proto definition:

```
message SubField1 {
  string fielda = 1;
}

message SuperSubField1 {
  string fielda = 1;
  string fieldb = 2;
}
```

If you read the JSON produced by SuperSubField1 into SubField1, an error is
thrown. This library fixes this backwards incompatibility issue.

## Generation Helpers
Some of the methods to build a protobuf a are a bit heavy weight. This module
provides a thin wrapper for some methods to make them more natural.

These helpers have been added in a separate module in hopes the default protobuf
library will add them

### Timestamp (Well Known Types)
The provided library requires the following code to generate a timestamp

```ruby
Google::Protobuf::Timestamp.new(seconds: Time.now.to_i, nanos: Time.now.nsec)
# or
stamp = Google::Protobuf::Timestamp.new
stamp.from_time(Time.now)
```

Both of these are unnecessarily verbose.

Instead consider:

```ruby
Protobuf3Fixer::GenerationHelpers.create_timestamp(Time.now)
```

