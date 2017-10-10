class AddHostInspectionFieldsToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.boolean :supports_https, default: false, nil: false
      t.boolean :host_connection_verified, default: nil, nil: true
      t.string :detected_web_host
    end
  end
end
