class BannedAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    banned_addresses = OfacAddress.pluck(:address)

    banned_addresses.each do |banned_address|
      if !banned_address.blank? && value.to_s.strip.downcase.include?(banned_address.to_s.strip.downcase)
        record.errors.add attribute.to_sym, "can't be a banned address"
      end
    end
  end
end
