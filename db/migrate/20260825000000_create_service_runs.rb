class CreateServiceRuns < ActiveRecord::Migration[7.2]
  def change
    create_table :service_runs, id: :uuid do |t|
      t.string :service_name, null: false
      t.timestamps
    end

    # Lookups are always "the latest run of service X".
    add_index :service_runs, [:service_name, :created_at], order: {created_at: :desc}
  end
end
