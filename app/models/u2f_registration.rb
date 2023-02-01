# typed: strict

class U2fRegistration < ApplicationRecord
  FORMATS = %w[u2f webauthn]
  enum format: FORMATS.zip(FORMATS).to_h

  belongs_to :publisher
end
