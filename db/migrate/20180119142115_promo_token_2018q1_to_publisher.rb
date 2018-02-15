class PromoToken2018q1ToPublisher < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :promo_token_2018q1, :string
  end
end
