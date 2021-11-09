# typed: true
# frozen_string_literal: true

module Gemini
  class User
    include Initializable

    attr_accessor :users
    attr_accessor :name
    attr_accessor :last_sign_in
    attr_accessor :status
    attr_accessor :country_code
    attr_accessor :is_verified
  end
end
