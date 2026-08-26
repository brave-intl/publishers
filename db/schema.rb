# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_25_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_enum :chain, [
    "SOL",
    "ETH",
  ], force: :cascade

  create_enum :chain, [
    "SOL",
    "ETH",
  ], force: :cascade

  create_table "active_analytics_browsers_per_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "name", null: false
    t.string "site", null: false
    t.bigint "total", default: 1, null: false
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["date", "site", "name"], name: "idx_on_date_site_name_8acaa57d8d"
  end

  create_table "active_analytics_views_per_days", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "date", null: false
    t.string "page", null: false
    t.string "referrer_host"
    t.string "referrer_path"
    t.string "site", null: false
    t.bigint "total", default: 1, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["date"], name: "index_active_analytics_views_per_days_on_date"
    t.index ["referrer_host", "referrer_path", "date"], name: "index_active_analytics_views_per_days_on_referrer_and_date"
    t.index ["site", "page", "date"], name: "index_active_analytics_views_per_days_on_site_and_date"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "legacy_record_id"
    t.string "name", null: false
    t.uuid "record_id"
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bitflyer_connections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "access_expiration_time", precision: nil
    t.text "access_token"
    t.string "country"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "default_currency"
    t.string "display_name"
    t.string "expires_in"
    t.boolean "is_verified"
    t.boolean "oauth_failure_email_sent", default: false, null: false
    t.boolean "oauth_refresh_failed", default: false, null: false
    t.boolean "payout_failed", default: false, null: false
    t.uuid "publisher_id", null: false
    t.string "recipient_id"
    t.text "refresh_token"
    t.string "scope"
    t.string "state_token"
    t.string "status"
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["is_verified"], name: "index_bitflyer_connections_on_is_verified"
    t.index ["publisher_id"], name: "index_bitflyer_connections_on_publisher_id"
    t.index ["recipient_id"], name: "index_bitflyer_connections_on_recipient_id", unique: true
    t.index ["status"], name: "index_bitflyer_connections_on_status"
  end

  create_table "cached_uphold_tips", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "amount"
    t.datetime "created_at", null: false
    t.string "settlement_amount"
    t.string "settlement_currency"
    t.datetime "updated_at", null: false
    t.uuid "uphold_connection_for_channel_id"
    t.datetime "uphold_created_at", precision: nil
    t.uuid "uphold_transaction_id"
    t.index ["uphold_transaction_id"], name: "index_cached_uphold_tips_on_uphold_transaction_id", unique: true
  end

  create_table "case_notes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "case_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.uuid "created_by_id"
    t.text "note"
    t.boolean "public", default: true, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["case_id"], name: "index_case_notes_on_case_id"
    t.index ["created_by_id"], name: "index_case_notes_on_created_by_id"
  end

  create_table "case_replies", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "cases", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "accident_question"
    t.uuid "assignee_id"
    t.serial "case_number", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "open_at", precision: nil
    t.uuid "publisher_id"
    t.text "solicit_question"
    t.string "status", default: "new"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["assignee_id"], name: "index_cases_on_assignee_id"
    t.index ["publisher_id"], name: "index_cases_on_publisher_id", unique: true
    t.index ["status"], name: "index_cases_on_status"
  end

  create_table "channel_transfers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "channel_id"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "suspended"
    t.uuid "transfer_from_id"
    t.uuid "transfer_to_channel_id"
    t.uuid "transfer_to_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["channel_id"], name: "index_channel_transfers_on_channel_id"
    t.index ["transfer_from_id"], name: "index_channel_transfers_on_transfer_from_id"
    t.index ["transfer_to_channel_id"], name: "index_channel_transfers_on_transfer_to_channel_id"
    t.index ["transfer_to_id"], name: "index_channel_transfers_on_transfer_to_id"
  end

  create_table "channels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "contest_timesout_at", precision: nil
    t.string "contest_token"
    t.uuid "contested_by_channel_id"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "created_via_api", default: false, null: false
    t.string "deposit_id"
    t.text "derived_brave_publisher_id"
    t.uuid "details_id"
    t.string "details_type"
    t.string "public_identifier"
    t.string "public_name"
    t.datetime "public_name_changed_at"
    t.uuid "publisher_id"
    t.datetime "updated_at", precision: nil, null: false
    t.string "verification_details"
    t.boolean "verification_pending", default: false, null: false
    t.string "verification_status"
    t.boolean "verified", default: false
    t.datetime "verified_at", precision: nil
    t.index "lower((public_identifier)::text)", name: "index_channels_on_lower_public_identifier", unique: true
    t.index "lower((public_name)::text)", name: "index_channels_on_lower_public_name", unique: true
    t.index ["contested_by_channel_id"], name: "index_channels_on_contested_by_channel_id"
    t.index ["details_type", "details_id"], name: "index_channels_on_details_type_and_details_id", unique: true
    t.index ["publisher_id"], name: "index_channels_on_publisher_id"
  end

  create_table "crypto_address_for_channels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.enum "chain", null: false, enum_type: "chain"
    t.uuid "channel_id", null: false
    t.datetime "created_at", null: false
    t.uuid "crypto_address_id", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "chain"], name: "unique_crypto_chain_for_channels", unique: true
    t.index ["channel_id"], name: "index_crypto_address_for_channels_on_channel_id"
    t.index ["crypto_address_id"], name: "index_crypto_address_for_channels_on_crypto_address_id"
  end

  create_table "crypto_addresses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "address", null: false
    t.enum "chain", null: false, enum_type: "chain"
    t.datetime "created_at", null: false
    t.uuid "publisher_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified"
    t.index ["publisher_id"], name: "index_crypto_addresses_on_publisher_id"
  end

  create_table "csp_violation_reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "report"
    t.datetime "updated_at", null: false
    t.index ["report"], name: "index_csp_violation_reports_on_report", unique: true
  end

  create_table "daily_metrics", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "date"
    t.string "name"
    t.jsonb "result"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["result"], name: "index_daily_metrics_on_result"
  end

  create_table "faq_categories", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.integer "rank"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_faq_categories_on_name", unique: true
    t.index ["rank"], name: "index_faq_categories_on_rank"
  end

  create_table "faqs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "answer"
    t.datetime "created_at", precision: nil, null: false
    t.uuid "faq_category_id"
    t.boolean "published", default: false
    t.string "question"
    t.integer "rank"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["faq_category_id"], name: "index_faqs_on_faq_category_id"
    t.index ["question"], name: "index_faqs_on_question", unique: true
    t.index ["rank"], name: "index_faqs_on_rank"
  end

  create_table "gemini_connection_for_channels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "channel_id", null: false
    t.string "channel_identifier"
    t.datetime "created_at", null: false
    t.uuid "gemini_connection_id", null: false
    t.string "recipient_id"
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_gemini_connection_for_channels_on_channel_id"
    t.index ["channel_identifier", "gemini_connection_id"], name: "unique_gemini_connection_for_channels", unique: true
    t.index ["gemini_connection_id"], name: "index_gemini_connection_for_channels_on_gemini_connection_id"
    t.index ["recipient_id"], name: "index_gemini_connection_for_channels_on_recipient_id"
  end

  create_table "gemini_connections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "access_expiration_time", precision: nil
    t.text "access_token"
    t.string "country"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "display_name"
    t.string "expires_in"
    t.boolean "is_verified"
    t.boolean "oauth_failure_email_sent", default: false, null: false
    t.boolean "oauth_refresh_failed", default: false, null: false
    t.boolean "payout_failed", default: false, null: false
    t.uuid "publisher_id", null: false
    t.string "recipient_id"
    t.integer "recipient_id_status", default: 0, null: false
    t.text "refresh_token"
    t.string "scope"
    t.string "state_token"
    t.string "status"
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["is_verified"], name: "index_gemini_connections_on_is_verified"
    t.index ["publisher_id"], name: "index_gemini_connections_on_publisher_id"
    t.index ["status"], name: "index_gemini_connections_on_status"
  end

  create_table "github_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_provider"
    t.string "channel_url"
    t.datetime "created_at", precision: nil, null: false
    t.string "github_channel_id"
    t.string "name"
    t.string "nickname"
    t.jsonb "stats"
    t.string "thumbnail_url"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["github_channel_id"], name: "index_github_channel_details_on_github_channel_id"
  end

  create_table "invoice_files", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.boolean "archived", default: false
    t.datetime "created_at", precision: nil, null: false
    t.uuid "invoice_id"
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "uploaded_by_id"
    t.index ["invoice_id"], name: "index_invoice_files_on_invoice_id"
    t.index ["uploaded_by_id"], name: "index_invoice_files_on_uploaded_by_id"
  end

  create_table "invoices", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "amount", default: "0"
    t.datetime "created_at", precision: nil, null: false
    t.date "date"
    t.string "finalized_amount"
    t.uuid "finalized_by_id"
    t.uuid "paid_by_id"
    t.date "payment_date"
    t.uuid "publisher_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["finalized_by_id"], name: "index_invoices_on_finalized_by_id"
    t.index ["paid_by_id"], name: "index_invoices_on_paid_by_id"
    t.index ["publisher_id"], name: "index_invoices_on_publisher_id"
  end

  create_table "legacy_publishers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_email"
    t.string "auth_name"
    t.string "auth_provider"
    t.string "auth_user_id"
    t.datetime "authentication_token_expires_at", precision: nil
    t.string "brave_publisher_id"
    t.string "brave_publisher_id_error_code"
    t.string "brave_publisher_id_unnormalized"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "created_via_api", default: false, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "default_currency"
    t.string "detected_web_host"
    t.string "email"
    t.string "encrypted_authentication_token"
    t.string "encrypted_authentication_token_iv"
    t.string "encrypted_uphold_access_parameters"
    t.string "encrypted_uphold_access_parameters_iv"
    t.string "encrypted_uphold_code"
    t.string "encrypted_uphold_code_iv"
    t.boolean "host_connection_verified"
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name"
    t.string "pending_email"
    t.string "phone"
    t.string "phone_normalized"
    t.boolean "show_verification_status"
    t.integer "sign_in_count", default: 0, null: false
    t.boolean "supports_https", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uphold_state_token"
    t.datetime "uphold_updated_at", precision: nil
    t.boolean "uphold_verified", default: false
    t.string "verification_method"
    t.string "verification_token"
    t.boolean "verified", default: false
    t.string "youtube_channel_id"
    t.index ["brave_publisher_id"], name: "index_legacy_publishers_on_brave_publisher_id"
    t.index ["created_at"], name: "index_legacy_publishers_on_created_at"
    t.index ["verification_token"], name: "index_legacy_publishers_on_verification_token"
    t.index ["verified"], name: "index_legacy_publishers_on_verified"
    t.index ["youtube_channel_id"], name: "index_legacy_publishers_on_youtube_channel_id"
  end

  create_table "legacy_totp_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.datetime "last_logged_in_at", precision: nil
    t.uuid "publisher_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publisher_id"], name: "index_legacy_totp_registrations_on_publisher_id"
  end

  create_table "legacy_youtube_channels", id: :string, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.integer "subscriber_count"
    t.string "thumbnail_url"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["id"], name: "index_legacy_youtube_channels_on_id", unique: true
  end

  create_table "login_activities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "accept_language"
    t.datetime "created_at", precision: nil, null: false
    t.uuid "publisher_id"
    t.datetime "updated_at", precision: nil, null: false
    t.text "user_agent"
    t.index ["created_at"], name: "index_login_activities_on_created_at"
    t.index ["publisher_id"], name: "index_login_activities_on_publisher_id"
  end

  create_table "memberships", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "ofac_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address", null: false
  end

  create_table "organization_permissions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.boolean "offline_reporting", default: false, null: false
    t.uuid "organization_id"
    t.boolean "referral_codes", default: false, null: false
    t.boolean "uphold_wallet", default: false, null: false
    t.index ["organization_id"], name: "index_organization_permissions_on_organization_id", unique: true
  end

  create_table "organizations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "payout_messages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message"
    t.uuid "payout_report_id", null: false
    t.uuid "publisher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["payout_report_id"], name: "index_payout_messages_on_payout_report_id"
    t.index ["publisher_id"], name: "index_payout_messages_on_publisher_id"
  end

  create_table "payout_reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "expected_num_payments"
    t.decimal "fee_rate"
    t.boolean "final"
    t.boolean "manual", default: false
    t.string "status"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "paypal_connections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "country"
    t.datetime "created_at", null: false
    t.string "encrypted_refresh_token"
    t.string "encrypted_refresh_token_iv"
    t.boolean "hidden", default: false
    t.text "payer_id"
    t.text "paypal_account_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.boolean "verified_account"
    t.index ["user_id"], name: "index_paypal_connections_on_user_id"
  end

  create_table "potential_payments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "address", null: false
    t.string "amount", null: false
    t.uuid "channel_id"
    t.jsonb "channel_stats", default: {}
    t.text "channel_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "fees", null: false
    t.uuid "finalized_by_id"
    t.boolean "gemini_is_verified", default: false
    t.uuid "invoice_id"
    t.string "kind", null: false
    t.string "name", null: false
    t.uuid "payout_report_id", null: false
    t.boolean "paypal_bank_account_attached", default: false, null: false
    t.uuid "publisher_id", null: false
    t.boolean "reauthorization_needed"
    t.string "status"
    t.boolean "suspended"
    t.datetime "updated_at", precision: nil, null: false
    t.string "uphold_id"
    t.boolean "uphold_member"
    t.string "uphold_status"
    t.string "url"
    t.integer "wallet_provider", limit: 2, default: 0
    t.string "wallet_provider_id"
    t.boolean "whitelisted", default: false, null: false
    t.index ["channel_id"], name: "index_potential_payments_on_channel_id"
    t.index ["finalized_by_id"], name: "index_potential_payments_on_finalized_by_id"
    t.index ["invoice_id"], name: "index_potential_payments_on_invoice_id"
    t.index ["payout_report_id"], name: "index_potential_payments_on_payout_report_id"
    t.index ["publisher_id"], name: "index_potential_payments_on_publisher_id"
  end

  create_table "previously_suspended_channels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "channel_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_identifier"], name: "index_previously_suspended_channels_on_channel_identifier", unique: true
  end

  create_table "promo_campaigns", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.uuid "publisher_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_promo_campaigns_on_name", unique: true
  end

  create_table "promo_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "aggregate_confirmations", default: 0, null: false
    t.integer "aggregate_downloads", default: 0, null: false
    t.integer "aggregate_installs", default: 0, null: false
    t.uuid "channel_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "installer_type"
    t.text "kind"
    t.uuid "promo_campaign_id"
    t.string "promo_id", null: false
    t.uuid "publisher_id"
    t.string "referral_code", null: false
    t.jsonb "stats", default: "{}"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["channel_id"], name: "index_promo_registrations_on_channel_id", unique: true
    t.index ["kind", "created_at"], name: "index_promo_registrations_on_kind_and_created_at"
    t.index ["promo_campaign_id"], name: "index_promo_registrations_on_promo_campaign_id"
    t.index ["promo_id", "referral_code"], name: "index_promo_registrations_on_promo_id_and_referral_code", unique: true
    t.index ["publisher_id"], name: "index_promo_registrations_on_publisher_id"
    t.index ["referral_code"], name: "index_promo_registrations_on_referral_code"
  end

  create_table "publisher_notes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "created_by_id", null: false
    t.text "note"
    t.uuid "publisher_id", null: false
    t.uuid "thread_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "zendesk_comment_id"
    t.string "zendesk_from_email"
    t.bigint "zendesk_ticket_id"
    t.string "zendesk_to_email"
    t.index ["created_by_id"], name: "index_publisher_notes_on_created_by_id"
    t.index ["publisher_id"], name: "index_publisher_notes_on_publisher_id"
    t.index ["thread_id"], name: "index_publisher_notes_on_thread_id"
    t.index ["zendesk_ticket_id", "zendesk_comment_id"], name: "index_publisher_notes_zendesk_ids", unique: true
  end

  create_table "publisher_status_updates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "publisher_id", null: false
    t.uuid "publisher_note_id"
    t.string "status", null: false
    t.index ["publisher_id", "created_at"], name: "index_publisher_status_updates_on_publisher_id_and_created_at"
    t.index ["publisher_note_id"], name: "index_publisher_status_updates_on_publisher_note_id"
  end

  create_table "publisher_whitelist_updates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", null: false
    t.uuid "publisher_id", null: false
    t.uuid "publisher_note_id"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_publisher_whitelist_updates_on_created_at"
    t.index ["publisher_id"], name: "index_publisher_whitelist_updates_on_publisher_id"
    t.index ["publisher_note_id"], name: "index_publisher_whitelist_updates_on_publisher_note_id"
    t.index ["updated_at"], name: "index_publisher_whitelist_updates_on_updated_at"
  end

  create_table "publishers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "agreed_to_tos", precision: nil
    t.string "bitflyer_deposit_id"
    t.boolean "blocked_country_exception", default: false
    t.datetime "created_at", precision: nil, null: false
    t.uuid "created_by_id"
    t.boolean "created_via_api", default: false, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "default_currency"
    t.datetime "default_currency_confirmed_at", precision: nil
    t.uuid "default_site_banner_id"
    t.boolean "default_site_banner_mode", default: false, null: false
    t.citext "email"
    t.boolean "excluded_from_payout", default: false, null: false
    t.jsonb "feature_flags", default: {}
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name", default: "", null: false
    t.string "pending_email"
    t.boolean "promo_enabled_2018q1", default: false
    t.string "promo_token_2018q1"
    t.text "role", default: "publisher"
    t.uuid "selected_wallet_provider_id"
    t.string "selected_wallet_provider_type"
    t.string "session_salt"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "site_channel_limit", default: 2
    t.boolean "subscribed_to_marketing_emails", default: false, null: false
    t.boolean "thirty_day_login", default: false, null: false
    t.datetime "two_factor_prompted_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["created_at"], name: "index_publishers_on_created_at"
    t.index ["created_by_id"], name: "index_publishers_on_created_by_id"
    t.index ["email"], name: "index_publishers_on_email", unique: true
    t.index ["pending_email"], name: "index_publishers_on_pending_email"
    t.index ["selected_wallet_provider_type", "selected_wallet_provider_id"], name: "publishers_wallet_provider_type"
  end

  create_table "reddit_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_provider"
    t.string "channel_url"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "nickname"
    t.string "reddit_channel_id"
    t.jsonb "stats"
    t.string "thumbnail_url"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["reddit_channel_id"], name: "index_reddit_channel_details_on_reddit_channel_id"
  end

  create_table "referral_totals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "paid"
    t.date "paid_at"
    t.uuid "publisher_id", null: false
    t.bigint "total", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_referral_totals_on_publisher_id"
  end

  create_table "reserved_public_names", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "permanent"
    t.string "public_name", null: false
    t.datetime "updated_at", null: false
    t.index ["public_name"], name: "index_reserved_public_names_on_public_name", unique: true
  end

  create_table "service_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.datetime "updated_at", null: false
    t.index ["service_name", "created_at"], name: "index_service_runs_on_service_name_and_created_at", order: { created_at: :desc }
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "site_banner_lookups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "channel_id", null: false
    t.text "channel_identifier", null: false
    t.datetime "created_at", null: false
    t.jsonb "derived_site_banner_info", null: false
    t.uuid "publisher_id", null: false
    t.text "sha2_base16", null: false
    t.datetime "updated_at", null: false
    t.uuid "wallet_address"
    t.index ["channel_id"], name: "index_site_banner_lookups_on_channel_id"
    t.index ["channel_identifier"], name: "index_site_banner_lookups_on_channel_identifier"
    t.index ["publisher_id"], name: "index_site_banner_lookups_on_publisher_id"
    t.index ["sha2_base16"], name: "index_gin_site_banner_lookups_on_sha2_base16", using: :gin
    t.index ["sha2_base16"], name: "index_site_banner_lookups_collation_c_on_sha_base16", opclass: :text_pattern_ops
    t.index ["sha2_base16"], name: "index_site_banner_lookups_on_sha2_base16"
  end

  create_table "site_banners", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "channel_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "default_donation"
    t.text "description", null: false
    t.integer "donation_amounts", array: true
    t.bigint "legacy_id"
    t.uuid "publisher_id", null: false
    t.json "social_links"
    t.text "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["channel_id"], name: "index_site_banners_on_channel_id"
    t.index ["publisher_id"], name: "index_site_banners_on_publisher_id"
  end

  create_table "site_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "ads_enabled_at", precision: nil
    t.string "brave_publisher_id"
    t.string "brave_publisher_id_error_code"
    t.string "brave_publisher_id_unnormalized"
    t.datetime "created_at", precision: nil, null: false
    t.string "detected_web_host"
    t.boolean "host_connection_verified"
    t.string "https_error"
    t.jsonb "stats", default: "{}", null: false
    t.boolean "supports_https", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "verification_method"
    t.string "verification_token"
  end

  create_table "stripe_connections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "access_token"
    t.jsonb "capabilities"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "default_currency"
    t.boolean "details_submitted"
    t.string "display_name"
    t.boolean "payouts_enabled"
    t.uuid "publisher_id", null: false
    t.text "refresh_token"
    t.string "scope"
    t.string "state_token"
    t.string "stripe_user_id"
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_stripe_connections_on_publisher_id"
  end

  create_table "totp_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "last_logged_in_at", precision: nil
    t.uuid "publisher_id"
    t.text "secret"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publisher_id"], name: "index_totp_registrations_on_publisher_id"
  end

  create_table "twitch_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_provider"
    t.string "auth_user_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "display_name"
    t.string "email"
    t.string "name"
    t.jsonb "stats", default: "{}", null: false
    t.string "thumbnail_url"
    t.string "twitch_channel_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["twitch_channel_id"], name: "index_twitch_channel_details_on_twitch_channel_id"
  end

  create_table "twitter_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_email"
    t.string "auth_provider"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "screen_name"
    t.jsonb "stats"
    t.string "thumbnail_url"
    t.string "twitter_channel_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["twitter_channel_id"], name: "index_twitter_channel_details_on_twitter_channel_id"
  end

  create_table "two_factor_authentication_removals", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "publisher_id", null: false
    t.boolean "removal_completed", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publisher_id"], name: "index_two_factor_authentication_removals_on_publisher_id"
  end

  create_table "u2f_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "certificate"
    t.integer "counter", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "format", default: "webauthn"
    t.string "key_handle"
    t.string "name"
    t.string "public_key"
    t.uuid "publisher_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["key_handle"], name: "index_u2f_registrations_on_key_handle"
    t.index ["publisher_id"], name: "index_u2f_registrations_on_publisher_id"
  end

  create_table "uphold_connection_for_channels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "address"
    t.string "card_id"
    t.uuid "channel_id", null: false
    t.string "channel_identifier"
    t.datetime "created_at", precision: nil, default: "2022-11-23 14:02:49", null: false
    t.string "currency"
    t.datetime "updated_at", precision: nil, default: "2022-11-23 14:02:49", null: false
    t.uuid "uphold_connection_id", null: false
    t.uuid "uphold_id"
    t.index ["channel_id"], name: "index_uphold_connection_for_channels_on_channel_id"
    t.index ["channel_identifier", "currency", "uphold_connection_id"], name: "unique_uphold_connection_for_channels", unique: true
    t.index ["channel_identifier"], name: "index_uphold_connection_for_channels_on_channel_identifier"
    t.index ["currency"], name: "index_uphold_connection_for_channels_on_currency"
    t.index ["uphold_connection_id"], name: "index_uphold_connection_for_channels_on_uphold_connection_id"
    t.index ["uphold_id"], name: "index_uphold_connection_for_channels_on_uphold_id"
  end

  create_table "uphold_connections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "access_expiration_time", precision: nil
    t.uuid "address"
    t.text "card_id"
    t.string "country"
    t.datetime "created_at", precision: nil, null: false
    t.string "default_currency"
    t.datetime "default_currency_confirmed_at", precision: nil
    t.boolean "is_member", default: false
    t.datetime "member_at", precision: nil
    t.boolean "oauth_failure_email_sent", default: false, null: false
    t.boolean "oauth_refresh_failed", default: false, null: false
    t.boolean "payout_failed", default: false, null: false
    t.uuid "publisher_id"
    t.datetime "send_emails", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.string "status"
    t.datetime "updated_at", precision: nil, null: false
    t.text "uphold_access_parameters"
    t.text "uphold_code"
    t.uuid "uphold_id"
    t.string "uphold_state_token"
    t.boolean "uphold_verified", default: false
    t.index ["card_id"], name: "index_uphold_connections_on_card_id"
    t.index ["publisher_id"], name: "index_uphold_connections_on_publisher_id", unique: true
    t.index ["uphold_id"], name: "index_uphold_connections_on_uphold_id"
  end

  create_table "uphold_status_reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "publisher_id"
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "uphold_id"
    t.index ["created_at"], name: "index_uphold_status_reports_on_created_at"
    t.index ["publisher_id"], name: "index_uphold_status_reports_on_publisher_id"
    t.index ["uphold_id"], name: "index_uphold_status_reports_on_uphold_id"
  end

  create_table "user_authentication_tokens", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "authentication_token"
    t.datetime "authentication_token_expires_at", precision: nil
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_user_authentication_tokens_on_user_id", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.uuid "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vimeo_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_provider"
    t.string "channel_url"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "nickname"
    t.jsonb "stats"
    t.string "thumbnail_url"
    t.datetime "updated_at", precision: nil, null: false
    t.string "vimeo_channel_id"
  end

  create_table "youtube_channel_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "auth_email"
    t.string "auth_name"
    t.string "auth_provider"
    t.string "auth_user_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.jsonb "stats", default: "{}", null: false
    t.integer "subscriber_count"
    t.string "thumbnail_url"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "youtube_channel_id"
    t.index ["youtube_channel_id"], name: "index_youtube_channel_details_on_youtube_channel_id"
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cases", "publishers", column: "assignee_id"
  add_foreign_key "channel_transfers", "publishers", column: "transfer_from_id"
  add_foreign_key "channel_transfers", "publishers", column: "transfer_to_id"
  add_foreign_key "channels", "channels", column: "contested_by_channel_id"
  add_foreign_key "invoice_files", "publishers", column: "uploaded_by_id"
  add_foreign_key "invoices", "publishers", column: "finalized_by_id"
  add_foreign_key "invoices", "publishers", column: "paid_by_id"
  add_foreign_key "publisher_notes", "publishers", column: "created_by_id"
end
