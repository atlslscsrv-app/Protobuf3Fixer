# Protobuf3Fixer

This gem is a thin wrapper to fix some of the non-conformance of the ruby
protobuff plugin

## Usage

```ruby
Protobuf3Fixer.decode_json(ProtobufMessageClass, json_string)
```

## Fixes

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
