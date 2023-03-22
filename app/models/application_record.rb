# typed: strict

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: {writing: :primary, reading: :secondary}

  # From https://pagertree.com/blog/migrate-attr_encrypted-to-rails-7-active-record-encrypts
  def self.encrypt_column_transition(name)
    if !ENV["PREPARING_DATABASE"].present?
      attr_encrypted_options[:key] = proc { |record| record.class.encryption_key }

      if column_names.include? "encrypted_#{name}"
        attr_encrypted name.to_sym
      end

      if column_names.include? "encrypted_#{name}_2"
        attr_encrypted "#{name}_2".to_sym
      end

      if column_names.include? name
        encrypts name.to_sym
      end
    end
  end
end
