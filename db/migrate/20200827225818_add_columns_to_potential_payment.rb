class AddColumnsToPotentialPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :potential_payments, :gemini_is_verified, :boolean, default: false
  end
end
