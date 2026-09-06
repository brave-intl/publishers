require "openssl"
require "digest/keccak"
require "rbnacl"
require "base58"

class Util::CryptoUtils
  class SignatureError < StandardError; end

  # Ethereum signs with secp256k1 and hashes with Keccak-256 -- the
  # pre-standardisation padding, which is *not* the SHA3-256 that OpenSSL
  # exposes, so the digest has to come from the keccak gem.
  SECP256K1_GROUP = OpenSSL::PKey::EC::Group.new("secp256k1")
  SECP256K1_ORDER = SECP256K1_GROUP.order

  # r (32) + s (32) + v (1)
  SIGNATURE_BYTES = 65

  # 0x04 tag + x (32) + y (32)
  PUBLIC_KEY_BYTES = 65

  # EIP-191 personal_sign envelope. Binary so that it can be concatenated with
  # a message of any encoding.
  PERSONAL_PREFIX = "\x19Ethereum Signed Message:\n".b.freeze

  def self.verify_solana_address(signature, address, message, current_publisher)
    verify_key = RbNaCl::VerifyKey.new(Base58.base58_to_binary(address, :bitcoin))
    verify_key.verify(Base58.base58_to_binary(signature, :bitcoin), message)
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end

  def self.verify_ethereum_address(signature, address, message, current_publisher)
    signature_address = personal_recover_address(message, signature)
    # Eth addresses are case insensitive
    signature_address == address.to_s.downcase
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end

  # Recovers the address that produced an EIP-191 personal_sign signature.
  # Returns a lowercase 0x-prefixed address; raises SignatureError if the
  # signature is malformed or does not recover to a point on the curve.
  def self.personal_recover_address(message, signature)
    public_key_to_address(personal_recover(message, signature))
  end

  # Returns the 65-byte uncompressed public key that signed +message+.
  def self.personal_recover(message, signature)
    blob = hex_to_bin(signature)
    unless blob.bytesize == SIGNATURE_BYTES
      raise SignatureError, "signature must be #{SIGNATURE_BYTES} bytes, got #{blob.bytesize}"
    end

    r = decode_scalar(blob[0, 32], "r")
    s = decode_scalar(blob[32, 32], "s")
    recover_public_key(keccak256(prefixed_message(message)), r, s, recovery_id(blob.getbyte(64)))
  end

  # Keccak-256 of the public key minus its 0x04 tag; the address is the low 20
  # bytes of that digest.
  def self.public_key_to_address(public_key)
    unless public_key.bytesize == PUBLIC_KEY_BYTES && public_key.getbyte(0) == 0x04
      raise SignatureError, "expected a 65-byte uncompressed public key"
    end

    "0x#{keccak256(public_key[1, 64])[-20..].unpack1("H*")}"
  end

  # ECDSA public key recovery: Q = r^-1 (sR - eG), where R is the curve point
  # whose x coordinate is r (offset by the group order when the recovery id
  # says the x coordinate overflowed) and whose y parity is the low bit of the
  # recovery id.
  def self.recover_public_key(message_hash, r, s, recovery_id)
    e = OpenSSL::BN.new(message_hash.unpack1("H*"), 16)
    x = r + OpenSSL::BN.new((recovery_id / 2).to_s) * SECP256K1_ORDER
    y_parity = (recovery_id & 1).zero? ? "02" : "03"

    # Point.new validates that x is in the field and lands on the curve.
    point = begin
      OpenSSL::PKey::EC::Point.new(
        SECP256K1_GROUP,
        OpenSSL::BN.new(y_parity + x.to_s(16).rjust(64, "0"), 16)
      )
    rescue OpenSSL::PKey::EC::Point::Error, OpenSSL::BNError => error
      raise SignatureError, "signature does not describe a curve point: #{error.message}"
    end

    r_inv = r.mod_inverse(SECP256K1_ORDER)
    # mul(a, b) == a * point + b * generator
    public_key = point.mul((s * r_inv) % SECP256K1_ORDER,
      ((SECP256K1_ORDER - (e % SECP256K1_ORDER)) * r_inv) % SECP256K1_ORDER)
    raise SignatureError, "recovered the point at infinity" if public_key.infinity?

    public_key.to_octet_string(:uncompressed)
  end

  def self.prefixed_message(message)
    body = message.to_s.b
    PERSONAL_PREFIX + body.bytesize.to_s + body
  end

  def self.keccak256(data)
    Digest::Keccak.digest(data, 256)
  end

  # Accepts 27/28 (the personal_sign convention), 0/1 (raw), and EIP-155
  # chain-encoded values.
  def self.recovery_id(v)
    id = if v >= 35
      (v - 35) % 2
    elsif v >= 27
      v - 27
    else
      v
    end
    raise SignatureError, "invalid recovery id from v=#{v}" unless (0..3).cover?(id)
    id
  end

  def self.decode_scalar(bytes, name)
    scalar = OpenSSL::BN.new(bytes.unpack1("H*"), 16)
    if scalar.zero? || scalar >= SECP256K1_ORDER
      raise SignatureError, "signature #{name} is outside the group order"
    end
    scalar
  end

  def self.hex_to_bin(hex)
    hex = hex.to_s.strip
    hex = hex[2..] if hex.start_with?("0x", "0X")
    raise SignatureError, "signature is not valid hex" unless hex.match?(/\A\h*\z/) && hex.length.even?
    [hex].pack("H*")
  end

  private_class_method :recover_public_key, :prefixed_message, :keccak256,
    :recovery_id, :decode_scalar, :hex_to_bin
end
