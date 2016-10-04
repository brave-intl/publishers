require "bitcoin"
class BitcoinAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !Bitcoin.valid_address?(value)
      record.errors[attribute] << (options[:message] || "is invalid")
    end
  end
end
