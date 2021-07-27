desc 'Rekey (change keys) of all encrypted fields'
task rekey: :environment do
  old_key = Rails.application.secrets[:attr_encrypted_key_old]
  new_key = Rails.application.secrets[:attr_encrypted_key]

  hash_model_to_columns = Util::AttrEncrypted.get_all_encrypted_fields

  ActiveRecord::Base.connection.truncate(UserAuthenticationToken.table_name)

  hash_model_to_columns.except(UserAuthenticationToken).each do |model, encrypted_fields|
    encrypted_fields.each do |field|
      puts "Rekeying #{model} #{field}"
      model.find_in_batches(batch_size: 10000) do |batch_of_records|
        updated_records = []
        batch_of_records.each do |record|
          Rails.logger.debug("Rekeying #{model} #{field} #{record.id}")

          # Get the old value for later comparison
          field_name_encrypted = record.send("encrypted_#{field}")
          old_field_name_iv = record.send("encrypted_#{field}_iv")

          if field_name_encrypted.blank? or old_field_name_iv.blank?
            Rails.logger.debug("Skipping #{model} #{field} #{record.id} due to this field being nil")
            next
          end

          begin
            old_field_value = Util::AttrEncrypted.get_value_using_key(record: record,
                                                                      field: field,
                                                                      key: old_key)
          rescue OpenSSL::Cipher::CipherError
            Rails.logger.debug("Already Rekeyed #{model} #{field} #{record.id}")
            # Already rekeyed
            next
          end

          # Perform the rekey on the object in memory using the new key
          Util::AttrEncrypted.rekey(object: record,
                                    field: field,
                                    old_key: old_key,
                                    new_key: new_key,
                                    field_value: old_field_value)

          updated_records << record
          Rails.logger.debug("Rekeyed #{model} #{field} #{record.id}")
        rescue OpenSSL::Cipher::CipherError => e
          raise "Cannot rekey #{model} #{field} #{record.id}, error: #{e.message}"
        end
        puts("Updating #{batch_of_records.size} #{model} records")

        if updated_records.present?
          Rails.logger.debug("Updated records: #{updated_records}")
          perform_sql_update(records: updated_records, field: field)
        end
      end
    end
  end
end

def perform_sql_update(records:, field:)
  # Using postgres UPDATE FROM syntax
  # https://www.postgresql.org/docs/current/sql-update.html
  record = records[0]
  table = record.class.table_name
  sql = """
              UPDATE #{table} as t
                SET encrypted_#{field} = c.encrypted_field,
                encrypted_#{field}_iv = c.encrypted_field_iv,
                updated_at = '#{Time.zone.now}'
              FROM (values
                  #{records.map { |r| "(  '#{r.id}'::UUID, '#{r.send("encrypted_#{field}")}', '#{r.send("encrypted_#{field}_iv")}'  )" }.join(",\n")}
              ) as c(id, encrypted_field, encrypted_field_iv)
              where c.id = t.id
              """
  Rails.logger.debug(sql)
  record.class.connection.execute(sql)
end
