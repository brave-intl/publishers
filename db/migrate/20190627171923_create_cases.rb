class CreateCases < ActiveRecord::Migration[5.2]
  def change
    create_table :cases, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      # This might be able to be genericized in the future through the use of CaseQuestions, etc.
      # But for now just these two fields on each case is probably fine
      t.text :solicit_question
      t.text :accident_question

      t.string :status, default: 'new'

      # The person the case belongs to
      t.belongs_to :publisher, index: { unique: true }, type: :uuid
      # Person working the case
      t.references :assignee, index: true, foreign_key: { to_table: :publishers }, type: :uuid

      t.datetime :open_at
      t.timestamps
    end
  end
end
