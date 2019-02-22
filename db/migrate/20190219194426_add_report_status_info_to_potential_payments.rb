class AddReportStatusInfoToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :uphold_status, :string
    add_column :potential_payments, :reauthorization_needed, :bool
    add_column :potential_payments, :uphold_member, :bool
    add_column :potential_payments, :suspended, :bool
  end
end
