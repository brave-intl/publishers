class CreateChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :channels, id: :uuid do |t|
      t.belongs_to :publisher, type: :uuid
      t.boolean :created_via_api, default: false, null: false
      t.boolean :show_verification_status
      t.boolean :verified, default: false
      t.references :details, type: :uuid, polymorphic: true, index: { unique: true}
      t.timestamps
    end

    create_table :site_channel_details, id: :uuid do |t|
      t.string :brave_publisher_id
      t.string :brave_publisher_id_unnormalized
      t.string :brave_publisher_id_error_code
      t.string :verification_token
      t.string :verification_method
      t.boolean :supports_https, default: false
      t.boolean :host_connection_verified
      t.string :detected_web_host
      t.timestamps
    end

    create_table :youtube_channel_details, id: :uuid do |t|
      t.references :youtube_channel, type: :string, index: { unique: true}
      t.string :auth_provider
      t.string :auth_user_id
      t.string :auth_email
      t.string :auth_name
      t.string   :title
      t.string   :description
      t.string   :thumbnail_url
      t.integer  :subscriber_count
      t.timestamps
    end
  end
end
