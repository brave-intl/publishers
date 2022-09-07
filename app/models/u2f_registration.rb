# typed: strict

class U2fRegistration < ApplicationRecord
  FORMATS = T.let(%w[u2f webauthn], T::Array[String])
  enum format: FORMATS.zip(FORMATS).to_h

  belongs_to :publisher
end
