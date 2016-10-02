class AddPhoneNumberFieldsToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :phone
      t.string :phone_normalized
    end
  end
end
