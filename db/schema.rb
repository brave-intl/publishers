# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_16_134245) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "channels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "publisher_id"
    t.boolean "created_via_api", default: false, null: false
    t.boolean "verified", default: false
    t.string "details_type"
    t.uuid "details_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_status"
    t.string "verification_details"
    t.datetime "verified_at"
    t.boolean "verification_pending", default: false, null: false
    t.uuid "contested_by_channel_id"
    t.string "contest_token"
    t.datetime "contest_timesout_at"
    t.index ["details_type", "details_id"], name: "index_channels_on_details_type_and_details_id", unique: true
    t.index ["publisher_id"], name: "index_channels_on_publisher_id"
  end

  create_table "faq_categories", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_faq_categories_on_name", unique: true
    t.index ["rank"], name: "index_faq_categories_on_rank"
  end

  create_table "faqs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "question"
    t.string "answer"
    t.integer "rank"
    t.uuid "faq_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false
    t.index ["faq_category_id"], name: "index_faqs_on_faq_category_id"
    t.index ["question"], name: "index_faqs_on_question", unique: true
    t.index ["rank"], name: "index_faqs_on_rank"
  end

  create_table "legacy_publisher_statements", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "publisher_id", null: false
    t.string "period"
    t.string "source_url"
    t.text "encrypted_contents"
    t.string "encrypted_contents_iv"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_legacy_publisher_statements_on_publisher_id"
  end

  create_table "legacy_publishers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "brave_publisher_id"
    t.string "name"
    t.string "email"
    t.string "verification_token"
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "phone"
    t.string "phone_normalized"
    t.string "encrypted_authentication_token"
    t.string "encrypted_authentication_token_iv"
    t.string "verification_method"
    t.datetime "authentication_token_expires_at"
    t.boolean "show_verification_status"
    t.boolean "created_via_api", default: false, null: false
    t.string "uphold_state_token"
    t.string "encrypted_uphold_code"
    t.string "encrypted_uphold_code_iv"
    t.string "encrypted_uphold_access_parameters"
    t.string "encrypted_uphold_access_parameters_iv"
    t.boolean "uphold_verified", default: false
    t.string "pending_email"
    t.boolean "supports_https", default: false
    t.boolean "host_connection_verified"
    t.string "detected_web_host"
    t.string "default_currency"
    t.string "auth_provider"
    t.string "auth_user_id"
    t.string "auth_name"
    t.string "auth_email"
    t.string "youtube_channel_id"
    t.string "brave_publisher_id_unnormalized"
    t.string "brave_publisher_id_error_code"
    t.datetime "uphold_updated_at"
    t.index ["brave_publisher_id"], name: "index_legacy_publishers_on_brave_publisher_id"
    t.index ["created_at"], name: "index_legacy_publishers_on_created_at"
    t.index ["verification_token"], name: "index_legacy_publishers_on_verification_token"
    t.index ["verified"], name: "index_legacy_publishers_on_verified"
    t.index ["youtube_channel_id"], name: "index_legacy_publishers_on_youtube_channel_id"
  end

  create_table "legacy_totp_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.uuid "publisher_id"
    t.datetime "last_logged_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_legacy_totp_registrations_on_publisher_id"
  end

  create_table "legacy_u2f_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "certificate"
    t.string "key_handle"
    t.string "public_key"
    t.integer "counter", null: false
    t.string "name"
    t.uuid "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_handle"], name: "index_legacy_u2f_registrations_on_key_handle"
    t.index ["publisher_id"], name: "index_legacy_u2f_registrations_on_publisher_id"
  end

  create_table "legacy_youtube_channels", id: :string, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "thumbnail_url"
    t.integer "subscriber_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_legacy_youtube_channels_on_id", unique: true
  end

  create_table "login_activities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "publisher_id"
    t.text "user_agent"
    t.text "accept_language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_login_activities_on_created_at"
    t.index ["publisher_id"], name: "index_login_activities_on_publisher_id"
  end

  create_table "payout_reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.boolean "final"
    t.decimal "fee_rate"
    t.string "amount"
    t.string "fees"
    t.integer "num_payments"
    t.text "encrypted_contents"
    t.string "encrypted_contents_iv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promo_campaigns", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_promo_campaigns_on_name", unique: true
  end

  create_table "promo_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "channel_id"
    t.string "promo_id", null: false
    t.string "referral_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "kind"
    t.jsonb "stats", default: "{}"
    t.uuid "promo_campaign_id"
    t.boolean "active", default: true, null: false
    t.index ["channel_id"], name: "index_promo_registrations_on_channel_id"
    t.index ["promo_campaign_id"], name: "index_promo_registrations_on_promo_campaign_id"
    t.index ["promo_id", "referral_code"], name: "index_promo_registrations_on_promo_id_and_referral_code", unique: true
  end

  create_table "publisher_notes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "publisher_id", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "created_by_id", null: false
    t.index ["created_by_id"], name: "index_publisher_notes_on_created_by_id"
    t.index ["publisher_id"], name: "index_publisher_notes_on_publisher_id"
  end

  create_table "publisher_status_updates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "publisher_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.index ["publisher_id", "created_at"], name: "index_publisher_status_updates_on_publisher_id_and_created_at"
  end

  create_table "publishers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "pending_email"
    t.string "phone"
    t.string "phone_normalized"
    t.string "encrypted_authentication_token"
    t.string "encrypted_authentication_token_iv"
    t.datetime "authentication_token_expires_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "created_via_api", default: false, null: false
    t.string "default_currency"
    t.string "uphold_state_token"
    t.boolean "uphold_verified", default: false
    t.string "encrypted_uphold_code"
    t.string "encrypted_uphold_code_iv"
    t.string "encrypted_uphold_access_parameters"
    t.string "encrypted_uphold_access_parameters_iv"
    t.datetime "uphold_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "two_factor_prompted_at"
    t.boolean "visible", default: true
    t.datetime "agreed_to_tos"
    t.boolean "promo_enabled_2018q1", default: false
    t.string "promo_token_2018q1"
    t.jsonb "promo_stats_2018q1", default: {}, null: false
    t.datetime "promo_stats_updated_at_2018q1"
    t.text "role", default: "publisher"
    t.datetime "javascript_last_detected_at"
    t.datetime "default_currency_confirmed_at"
    t.boolean "excluded_from_payout", default: false, null: false
    t.index "lower((email)::text)", name: "index_publishers_on_lower_email", unique: true
    t.index ["created_at"], name: "index_publishers_on_created_at"
    t.index ["pending_email"], name: "index_publishers_on_pending_email"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "site_banners", force: :cascade do |t|
    t.uuid "publisher_id", null: false
    t.text "title", null: false
    t.text "description", null: false
    t.integer "donation_amounts", null: false, array: true
    t.integer "default_donation", null: false
    t.json "social_links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_site_banners_on_publisher_id"
  end

  create_table "site_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "brave_publisher_id"
    t.string "brave_publisher_id_unnormalized"
    t.string "brave_publisher_id_error_code"
    t.string "verification_token"
    t.string "verification_method"
    t.boolean "supports_https", default: false
    t.boolean "host_connection_verified"
    t.string "detected_web_host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stats", default: "{}", null: false
  end

  create_table "totp_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.uuid "publisher_id"
    t.datetime "last_logged_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_totp_registrations_on_publisher_id"
  end

  create_table "twitch_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "twitch_channel_id"
    t.string "auth_provider"
    t.string "auth_user_id"
    t.string "email"
    t.string "name"
    t.string "display_name"
    t.string "thumbnail_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stats", default: "{}", null: false
    t.index ["twitch_channel_id"], name: "index_twitch_channel_details_on_twitch_channel_id"
  end

  create_table "twitter_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "twitter_channel_id"
    t.string "auth_provider"
    t.string "auth_email"
    t.string "name"
    t.string "screen_name"
    t.string "thumbnail_url"
    t.jsonb "stats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["twitter_channel_id"], name: "index_twitter_channel_details_on_twitter_channel_id"
  end

  create_table "u2f_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "certificate"
    t.string "key_handle"
    t.string "public_key"
    t.integer "counter", null: false
    t.string "name"
    t.uuid "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_handle"], name: "index_u2f_registrations_on_key_handle"
    t.index ["publisher_id"], name: "index_u2f_registrations_on_publisher_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "youtube_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "youtube_channel_id"
    t.string "auth_provider"
    t.string "auth_user_id"
    t.string "auth_email"
    t.string "auth_name"
    t.string "title"
    t.string "description"
    t.string "thumbnail_url"
    t.integer "subscriber_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stats", default: "{}", null: false
    t.index ["youtube_channel_id"], name: "index_youtube_channel_details_on_youtube_channel_id"
  end

  add_foreign_key "channels", "channels", column: "contested_by_channel_id"
  add_foreign_key "publisher_notes", "publishers", column: "created_by_id"
end
