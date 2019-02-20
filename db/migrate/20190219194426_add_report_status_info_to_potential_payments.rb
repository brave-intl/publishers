class AddReportStatusInfoToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :uphold_status_was, :string
    add_column :potential_payments, :reauthorization_was_needed, :bool
    add_column :potential_payments, :was_uphold_member, :bool
    add_column :potential_payments, :was_suspended, :bool
  end
end
