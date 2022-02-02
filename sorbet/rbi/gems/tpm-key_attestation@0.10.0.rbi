# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `tpm-key_attestation` gem.
# Please instead update this file by running `bin/tapioca gem tpm-key_attestation`.

module TPM; end

class TPM::AIKCertificate < ::SimpleDelegator
  def conformant?; end

  private

  def empty_subject?; end
  def extension(oid); end
  def in_use?; end
  def san_extension; end
  def san_name; end
  def tpm_manufacturer; end
  def tpm_model; end
  def tpm_version; end
  def valid_basic_constraints?; end
  def valid_extended_key_usage?; end
  def valid_subject_alternative_name?; end
  def valid_version?; end

  class << self
    def from_der(certificate_der); end
  end
end

TPM::AIKCertificate::ASN_V3 = T.let(T.unsafe(nil), Integer)
TPM::AIKCertificate::EMPTY_NAME = T.let(T.unsafe(nil), OpenSSL::X509::Name)
TPM::AIKCertificate::OID_TCG = T.let(T.unsafe(nil), String)
TPM::AIKCertificate::OID_TCG_AT_TPM_MANUFACTURER = T.let(T.unsafe(nil), String)
TPM::AIKCertificate::OID_TCG_AT_TPM_MODEL = T.let(T.unsafe(nil), String)
TPM::AIKCertificate::OID_TCG_AT_TPM_VERSION = T.let(T.unsafe(nil), String)
TPM::AIKCertificate::OID_TCG_KP_AIK_CERTIFICATE = T.let(T.unsafe(nil), String)
TPM::AIKCertificate::SAN_DIRECTORY_NAME = T.let(T.unsafe(nil), Integer)
TPM::ALG_ECC = T.let(T.unsafe(nil), Integer)
TPM::ALG_ECDSA = T.let(T.unsafe(nil), Integer)
TPM::ALG_NULL = T.let(T.unsafe(nil), Integer)
TPM::ALG_RSA = T.let(T.unsafe(nil), Integer)
TPM::ALG_RSAPSS = T.let(T.unsafe(nil), Integer)
TPM::ALG_RSASSA = T.let(T.unsafe(nil), Integer)
TPM::ALG_SHA1 = T.let(T.unsafe(nil), Integer)
TPM::ALG_SHA256 = T.let(T.unsafe(nil), Integer)
TPM::ALG_SHA384 = T.let(T.unsafe(nil), Integer)
TPM::ALG_SHA512 = T.let(T.unsafe(nil), Integer)

class TPM::CertifyValidator
  def initialize(info, signature, nonce, public_area, signature_algorithm: T.unsafe(nil), hash_algorithm: T.unsafe(nil)); end

  def hash_algorithm; end
  def info; end
  def nonce; end
  def public_area; end
  def signature; end
  def signature_algorithm; end
  def valid?(signing_key); end

  private

  def attest; end
  def openssl_hash_function; end
  def openssl_signature_algorithm_class; end
  def openssl_signature_algorithm_parameters; end
  def valid_info?; end
  def valid_signature?(verify_key); end
end

TPM::CertifyValidator::TPM_HASH_ALG_TO_OPENSSL = T.let(T.unsafe(nil), Hash)
TPM::CertifyValidator::TPM_SIGNATURE_ALG_TO_OPENSSL = T.let(T.unsafe(nil), Hash)
TPM::ECC_NIST_P256 = T.let(T.unsafe(nil), Integer)
TPM::ECC_NIST_P384 = T.let(T.unsafe(nil), Integer)
TPM::ECC_NIST_P521 = T.let(T.unsafe(nil), Integer)
TPM::GENERATED_VALUE = T.let(T.unsafe(nil), Integer)

class TPM::KeyAttestation
  def initialize(certify_info, signature, certified_key, certificates, qualifying_data, signature_algorithm: T.unsafe(nil), hash_algorithm: T.unsafe(nil), root_certificates: T.unsafe(nil)); end

  def certificates; end
  def certified_key; end
  def certify_info; end
  def hash_algorithm; end
  def key; end
  def qualifying_data; end
  def root_certificates; end
  def signature; end
  def signature_algorithm; end
  def valid?; end

  private

  def aik_certificate; end
  def certify_validator; end
  def public_area; end
  def trust_store; end
  def trustworthy?; end
end

class TPM::KeyAttestation::Error < ::StandardError; end
TPM::KeyAttestation::ROOT_CERTIFICATES = T.let(T.unsafe(nil), Array)
TPM::KeyAttestation::VERSION = T.let(T.unsafe(nil), String)

class TPM::PublicArea
  def initialize(object); end

  def ecc?; end
  def key; end
  def name; end
  def object; end
  def openssl_curve_name; end

  private

  def name_alg; end
  def name_digest; end
  def t_public; end
end

class TPM::SAttest < ::BinData::Record
  class << self
    def deserialize(io, *args, &block); end
  end
end

class TPM::SAttest::SCertifyInfo < ::BinData::Record; end
TPM::ST_ATTEST_CERTIFY = T.let(T.unsafe(nil), Integer)
class TPM::SizedBuffer < ::BinData::Record; end
TPM::TPM_TO_OPENSSL_HASH_ALG = T.let(T.unsafe(nil), Hash)

class TPM::TPublic < ::BinData::Record
  def ecc?; end
  def key; end
  def openssl_curve_name; end
  def rsa?; end

  private

  def bn(data); end
  def ecc_key; end
  def rsa_key; end

  class << self
    def deserialize(io, *args, &block); end
  end
end

TPM::TPublic::BN_BASE = T.let(T.unsafe(nil), Integer)
TPM::TPublic::BYTE_LENGTH = T.let(T.unsafe(nil), Integer)
TPM::TPublic::CURVE_TPM_TO_OPENSSL = T.let(T.unsafe(nil), Hash)
TPM::TPublic::ECC_UNCOMPRESSED_POINT_INDICATOR = T.let(T.unsafe(nil), String)
TPM::TPublic::RSA_KEY_DEFAULT_PUBLIC_EXPONENT = T.let(T.unsafe(nil), Integer)
class TPM::TPublic::SEccParms < ::BinData::Record; end
class TPM::TPublic::SRsaParms < ::BinData::Record; end

class TPM::Tpm2bName < ::BinData::Record
  def valid_for?(other_name); end
end

class TPM::TpmtHa < ::BinData::Record; end
TPM::TpmtHa::BYTE_LENGTH = T.let(T.unsafe(nil), Integer)
TPM::TpmtHa::DIGEST_LENGTH_SHA1 = T.let(T.unsafe(nil), Integer)
TPM::TpmtHa::DIGEST_LENGTH_SHA256 = T.let(T.unsafe(nil), Integer)
TPM::VENDOR_IDS = T.let(T.unsafe(nil), Hash)