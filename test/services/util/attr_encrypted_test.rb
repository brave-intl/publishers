# typed: ignore
require "test_helper"

class AttrEncryptedTest < ActiveSupport::TestCase
  test "returns nil if iv is nil, even if contents exist" do
    old_key = "123"
    new_key = "456"

    uphold_connection = uphold_connections(:unprompted_connection)

    assert_nil uphold_connection.encrypted_uphold_access_parameters_iv
    assert_nil uphold_connection.encrypted_uphold_access_parameters

    result = Util::AttrEncrypted.rekey(object: uphold_connection,
      field: :uphold_access_parameters,
      old_key: old_key,
      new_key: new_key,
      field_value: "1")

    assert_nil result

    uphold_connection.encrypted_uphold_access_parameters = "123"
    uphold_connection.save!(validate: false)
    uphold_connection.reload
    refute_nil uphold_connection.encrypted_uphold_access_parameters

    result = Util::AttrEncrypted.rekey(object: uphold_connection,
      field: :uphold_access_parameters,
      old_key: old_key,
      new_key: new_key,
      field_value: "1")

    assert_nil result
  end
end
