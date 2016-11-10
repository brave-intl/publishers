class AddVerificationMethodToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :verification_method
    end
  end
end
