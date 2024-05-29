class BannedAddressValidator < ActiveModel::EachValidator
  MSG = "can't be a banned address"
  def validate_each(record, attribute, value)
    banned_addresses = OfacAddress.pluck(:address)

    banned_addresses.each do |banned_address|
      stripped_ba = banned_address.to_s.strip.downcase
      stripped_val = value.to_s.strip.downcase
      if (stripped_ba.present? && stripped_val.present?) && (stripped_val.include?(stripped_ba) || stripped_ba.include?(stripped_val))
        record.errors.add attribute.to_sym, MSG
      end
    end
  end
end
