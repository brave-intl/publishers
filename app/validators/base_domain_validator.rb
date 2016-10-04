class BaseDomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if PublicSuffix.domain(value).nil?
      record.errors[attribute] << (options[:message] || "is invalid")
    end
  end
end
