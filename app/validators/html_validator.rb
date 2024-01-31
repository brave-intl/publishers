# typed: true

class HtmlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.instance_of?(String) && ERB::Util::HTML_ESCAPE_ONCE_REGEXP.match?(value)
      record.errors.add(attribute, options[:message] || "contains html sequences")
    end
  end
end
