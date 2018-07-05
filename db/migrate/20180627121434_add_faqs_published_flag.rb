class AddFaqsPublishedFlag < ActiveRecord::Migration[5.0]
  def change
    add_column :faqs, :published, :bool, default: false
  end
end
