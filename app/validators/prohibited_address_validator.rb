class ProhibitedAddressValidator < ActiveModel::EachValidator
  MSG = "can't be a prohibited address"
  def validate_each(record, attribute, value)
    prohibited_addresses = ProhibitedList.pluck(:address)

    prohibited_addresses.each do |prohibited_address|
      stripped_ba = prohibited_address.to_s.strip.downcase
      stripped_val = value.to_s.strip.downcase
      if stripped_ba.present? && stripped_val.present? && (stripped_val.include?(stripped_ba) || stripped_ba.include?(stripped_val))
        record.errors.add attribute.to_sym, MSG
      end
    end
  end
end
