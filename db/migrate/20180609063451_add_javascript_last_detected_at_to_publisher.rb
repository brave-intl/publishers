class AddJavascriptLastDetectedAtToPublisher < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :javascript_last_detected_at, :datetime
  end
end
