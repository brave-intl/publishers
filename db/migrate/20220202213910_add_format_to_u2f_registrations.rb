class AddFormatToU2fRegistrations < ActiveRecord::Migration[6.1]
  def change
    add_column :u2f_registrations, :format, :string, default: 'webauthn'
  end
end
