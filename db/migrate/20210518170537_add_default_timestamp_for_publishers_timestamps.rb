class AddDefaultTimestampForPublishersTimestamps < ActiveRecord::Migration[6.0]
  def change
    change_column_default :publishers, :created_at, from: nil, to: ->{ 'current_timestamp' }
    change_column_default :publishers, :updated_at, from: nil, to: ->{ 'current_timestamp' }
  end
end
