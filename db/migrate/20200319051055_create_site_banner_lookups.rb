class CreateSiteBannerLookups < ActiveRecord::Migration[6.0]
  def change
    create_table :site_banner_lookups, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      # (Albert Wang) It seems B-tree is smart enough for LIKE %, so we don't need separate columns for the index, though hashing each nibble would be faster (wider columns though)
      # https://www.postgresql.org/docs/9.3/indexes-types.html
      # TL;DR: The optimizer can also use a B-tree index for queries involving the pattern matching operators LIKE and ~ if the pattern is a constant and is anchored to the beginning of the string — for example, col LIKE 'foo%' or col ~ '^foo', but not col LIKE '%bar'.
      t.text :sha2_base16, index: true, null: false
      t.jsonb :derived_site_banner_info, null: false
      t.text :channel_identifier, null: false, unique: true, index: true
      t.references :channel, type: :uuid, index: true, null: false
      t.references :publisher, type: :uuid, index: true, null: false
      t.integer :wallet_address
      t.integer :wallet_status, null: false
    end
  end
end
