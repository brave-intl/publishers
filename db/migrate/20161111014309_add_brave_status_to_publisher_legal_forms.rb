class AddBraveStatusToPublisherLegalForms < ActiveRecord::Migration[5.0]
  def change
    change_table :publisher_legal_forms do |t|
      t.string :brave_status
    end
  end
end
