class CreateDailyMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_metrics, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.string :name
      t.json :result
      t.date :date
      t.timestamps
    end
  end
end
