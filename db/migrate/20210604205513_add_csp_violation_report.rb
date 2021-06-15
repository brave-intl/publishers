class AddCspViolationReport < ActiveRecord::Migration[6.0]
  def change
    create_table :csp_violation_reports, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.jsonb    "report", defaults: {}, index: { unique: true }
      t.timestamps
    end
  end
end
